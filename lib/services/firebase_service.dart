import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // ===== Authentication Functions =====

  Future<String> signUp({
    required String email,
    required String password,
    required String username,
    required String role,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(email).set({
        'username': username,
        'email': email,
        'role': role,
      });

      return 'success';
    } on FirebaseAuthException catch (e) {
      return switch (e.code) {
        'email-already-in-use' => 'Email sudah terdaftar',
        'weak-password' => 'Password terlalu lemah',
        _ => 'Terjadi kesalahan saat mendaftar',
      };
    }
  }

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        String email = user.email ?? '';
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(email).get();

        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        String? token = await _firebaseMessaging.getToken();
        if (token != null) {
          List<String> tokens = List<String>.from(userData?['fcmTokens'] ?? []);

          if (!tokens.contains(token)) {
            tokens.add(token);
          }

          await _firestore.collection('users').doc(email).set({
            'fcmTokens': tokens,
            'role': userData?['role'],
            'username': userData?['username'],
          }, SetOptions(merge: true));
        }

        return {
          'success': true,
          'email': email,
          'role': userData?['role'] ?? '',
          'username': userData?['username'] ?? '',
        };
      }
      throw Exception('User tidak ditemukan');
    } on FirebaseAuthException {
      return {'success': false, 'message': 'Email atau kata sandi salah'};
    }
  }

  Future<void> signOutUser({required String email}) async {
    final currentToken = await _firebaseMessaging.getToken();
    if (currentToken != null) {
      await _firestore.collection('users').doc(email).update({
        'fcmTokens': FieldValue.arrayRemove([currentToken])
      });
    }
    await _auth.signOut();
  }

  // ===== Class Management Functions =====

  Future<void> addClass({
    required String classCode,
    required String className,
    required String? classIconName,
    required String email,
    required String role,
  }) async {
    final classData = {
      'id': classCode,
      'classCode': classCode,
      'className': className,
      'classIconName': classIconName,
      'members': [
        {'email': email, 'role': role}
      ],
    };

    await _firestore.collection('classes').doc(classCode).set(classData);

    await _createAndSendNotification(
      type: 'Kelas Dibuat',
      message: 'Anda telah membuat kelas $className',
      recipients: [email],
    );
  }

  Future<void> deleteClass({required String classCode}) async {
    try {
      final classDoc = _firestore.collection('classes').doc(classCode);
      final classData = await classDoc.get();

      if (!classData.exists) throw Exception('Kelas tidak ditemukan');

      final className = classData['className'];
      final recipientEmails = (classData['members'] as List)
          .map<String>((m) => m['email'].toString())
          .toList();

      // Hapus semua dokumen tugas dan pengumpulan terkait
      final tasksCollection = classDoc.collection('tasks');
      final tasksSnapshot = await tasksCollection.get();
      for (var taskDoc in tasksSnapshot.docs) {
        // Hapus semua pengumpulan terkait tugas
        final submissionsCollection =
            taskDoc.reference.collection('submissions');
        final submissionsSnapshot = await submissionsCollection.get();
        for (var submissionDoc in submissionsSnapshot.docs) {
          await submissionDoc.reference.delete();
        }
        // Hapus dokumen tugas
        await taskDoc.reference.delete();
      }

      // Hapus dokumen kelas
      await classDoc.delete();

      if (recipientEmails.isNotEmpty) {
        await _createAndSendNotification(
          type: 'Kelas Dihapus',
          message: 'Kelas $className telah dihapus',
          recipients: recipientEmails,
        );
      }
    } catch (e) {
      throw Exception('Gagal menghapus kelas: $e');
    }
  }

  Future<void> updateClassName({
    required String classCode,
    required String newClassName,
  }) async {
    final classDoc = _firestore.collection('classes').doc(classCode);
    final classData = await classDoc.get();

    if (!classData.exists) throw Exception('Kelas tidak ditemukan');

    final oldClassName = classData['className'];
    await classDoc.update({'className': newClassName});

    final recipientEmails = (classData['members'] as List)
        .map<String>((m) => m['email'].toString())
        .toList();

    if (recipientEmails.isNotEmpty) {
      await _createAndSendNotification(
        type: 'Nama Kelas Diubah',
        message: 'Nama kelas $oldClassName telah diubah menjadi $newClassName',
        recipients: recipientEmails,
      );
    }
  }

  Future<void> joinClass({
    required String kodeKelas,
    required String email,
    required String role,
  }) async {
    final classDoc = _firestore.collection('classes').doc(kodeKelas);

    var classData = await classDoc.get();
    if (!classData.exists) {
      throw Exception('Kelas tidak ditemukan');
    }

    final className = classData.data()?['className'];
    var members =
        List<Map<String, dynamic>>.from(classData.data()?['members'] ?? []);

    bool isAlreadyMember = members.any((m) => m['email'] == email);
    if (isAlreadyMember) {
      throw Exception('Anda sudah menjadi anggota kelas ini');
    }

    await classDoc.update({
      'members': FieldValue.arrayUnion([
        {'email': email, 'role': role}
      ])
    });

    classData = await classDoc.get();
    members =
        List<Map<String, dynamic>>.from(classData.data()?['members'] ?? []);

    List<String> recipientEmails =
        members.map<String>((m) => m['email'].toString()).toList();

    await _createAndSendNotification(
      type: 'Anggota Baru',
      message: '$email telah bergabung ke kelas $className',
      recipients: recipientEmails,
    );
  }

  Stream<List<Map<String, dynamic>>> getAllClasses({required String email}) {
    return _firestore
        .collection('classes')
        .orderBy('className', descending: false)
        .snapshots()
        .asyncMap((snapshot) async {
      final classes = List<Map<String, dynamic>>.from(
          snapshot.docs.map((doc) => doc.data()).toList());

      return classes.where((classData) {
        List<dynamic> members = classData['members'] ?? [];
        return members.any((member) => member['email'] == email);
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getClassMembers(
      {required String classCode}) {
    return _firestore
        .collection('classes')
        .doc(classCode)
        .snapshots()
        .asyncMap((classDoc) async {
      final classMembers =
          List<Map<String, dynamic>>.from(classDoc['members'] ?? []);

      // Dapatkan username untuk setiap member
      final members = await Future.wait(
        classMembers.map((member) async {
          final userDoc =
              await _firestore.collection('users').doc(member['email']).get();

          return {
            ...member,
            'username': userDoc.data()?['username'] ?? '',
          };
        }),
      );

      return members;
    });
  }

  Future<List<Map<String, dynamic>>> getNonClassMembers(
      {required String classCode}) async {
    final classDoc =
        await _firestore.collection('classes').doc(classCode).get();
    final classMembers =
        List<Map<String, dynamic>>.from(classDoc['members'] ?? []);

    final snapshot = await _firestore.collection('users').get();
    final nonMembers = snapshot.docs
        .map((doc) => {'email': doc['email'], 'role': doc['role']})
        .where((member) => !classMembers
            .any((classMember) => classMember['email'] == member['email']))
        .toList();

    return nonMembers;
  }

  Future<void> addMembersToClass({
    required String classCode,
    required List<Map<String, String>> members,
  }) async {
    final classDoc = _firestore.collection('classes').doc(classCode);
    final classData = await classDoc.get();
    final className = classData.data()?['className'];

    await classDoc.update({'members': FieldValue.arrayUnion(members)});

    final recipientEmails = (classData.data()?['members'] as List)
        .map((m) => m['email'].toString())
        .toList();

    for (var member in members) {
      final userDoc =
          await _firestore.collection('users').doc(member['email']).get();
      final username = userDoc.data()?['username'] ?? '';

      await _createAndSendNotification(
        type: 'Anggota Baru',
        message: '$username telah bergabung ke kelas $className',
        recipients: recipientEmails,
      );
    }
  }

  Future<void> removeMemberFromClass(
      {required String classCode, required String email}) async {
    final classDoc = _firestore.collection('classes').doc(classCode);
    var classData = await classDoc.get();

    final className = classData.data()?['className'];
    final members =
        List<Map<String, dynamic>>.from(classData.data()?['members']);
    final memberToRemove =
        members.firstWhere((member) => member['email'] == email);

    await classDoc.update({
      'members': FieldValue.arrayRemove([memberToRemove])
    });

    classData = await classDoc.get();
    var updatedMembers =
        List<Map<String, dynamic>>.from(classData.data()?['members'] ?? []);

    List<String> recipientEmails =
        updatedMembers.map<String>((m) => m['email'].toString()).toList();

    await _createAndSendNotification(
      type: 'Anggota Keluar',
      message: '$email telah keluar dari kelas $className',
      recipients: recipientEmails,
    );
  }

  // ===== Task Management Functions =====

  Future<void> addTaskToClass({
    required String taskId,
    required String classCode,
    required String taskName,
    required String description,
    required DateTime taskDeadline,
    required DateTime taskCloseDeadline,
    required String teacherEmail,
    required String? attachmentTaskUrl,
    required List<String> taskMembers,
  }) async {
    if (taskName.isEmpty) {
      throw Exception('Data tugas tidak lengkap');
    }

    // Ambil data member siswa dari kelas
    final classDoc =
        await _firestore.collection('classes').doc(classCode).get();
    final members = List<Map<String, dynamic>>.from(classDoc['members'] ?? []);

    final taskData = {
      'id': taskId,
      'classCode': classCode,
      'taskName': taskName,
      'description': description,
      'taskDeadline': Timestamp.fromDate(taskDeadline),
      'taskCloseDeadline': Timestamp.fromDate(taskCloseDeadline),
      'attachmentTaskUrl': attachmentTaskUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': teacherEmail,
      'taskMembers': taskMembers,
    };

    await _firestore
        .collection('classes')
        .doc(classCode)
        .collection('tasks')
        .doc(taskId)
        .set(taskData);

    final className = classDoc['className'];

    List<String> recipientEmails =
        members.map<String>((m) => m['email'].toString()).toList();

    await _createAndSendNotification(
      type: 'Tugas Baru',
      message: '$taskName telah ditambahkan di kelas $className',
      recipients: recipientEmails,
    );
  }

  Future<List<Map<String, dynamic>>> getNonTaskMembers({
    required String classCode,
    required String taskId,
  }) async {
    try {
      // Ambil semua anggota kelas
      final classDoc =
          await _firestore.collection('classes').doc(classCode).get();
      final classMembers =
          List<Map<String, dynamic>>.from(classDoc.data()?['members'] ?? []);

      // Ambil data username untuk setiap anggota
      List<Map<String, dynamic>> membersWithUsername = [];
      for (var member in classMembers) {
        final userDoc =
            await _firestore.collection('users').doc(member['email']).get();
        final username = userDoc.data()?['username'] ?? '';
        membersWithUsername.add({
          ...member,
          'username': username,
        });
      }

      // Jika ini tugas baru, return semua anggota
      if (taskId.isEmpty) {
        return membersWithUsername
            .where((member) => member['role'] == 'Siswa')
            .toList();
      }

      // Ambil anggota yang sudah ada di tugas
      final taskSubmissions = await _firestore
          .collection('classes')
          .doc(classCode)
          .collection('tasks')
          .doc(taskId)
          .collection('submissions')
          .get();

      final existingMembers =
          taskSubmissions.docs.map((doc) => doc.id).toList();

      // Filter anggota yang belum ada di tugas
      return membersWithUsername
          .where((member) =>
              member['role'] == 'Siswa' &&
              !existingMembers.contains(member['email']))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data anggota: $e');
    }
  }

  Future<Map<String, dynamic>> getTaskById({
    required String classCode,
    required String taskId,
    required String email,
  }) async {
    final taskDoc = await _firestore
        .collection('classes')
        .doc(classCode)
        .collection('tasks')
        .doc(taskId)
        .get();

    final classDoc =
        await _firestore.collection('classes').doc(classCode).get();

    final submissionDoc =
        await taskDoc.reference.collection('submissions').doc(email).get();

    return {
      'id': taskDoc.id,
      'classCode': taskDoc.data()?['classCode'],
      'className': classDoc['className'],
      ...taskDoc.data() ?? {},
      'submission': submissionDoc.exists
          ? submissionDoc.data()
          : {
              'taskId': taskId,
              'email': email,
              'score': null,
              'gradedAt': null,
              'submittedAt': null,
              'attachmentUrl': null,
              'feedback': null,
            }
    };
  }

  Stream<List<Map<String, dynamic>>> getTasksByEmail({required String email}) {
    return _firestore
        .collectionGroup('tasks')
        .snapshots()
        .asyncMap((tasksSnapshot) async {
      List<Map<String, dynamic>> tasks = [];

      for (var taskDoc in tasksSnapshot.docs) {
        final taskMembers =
            List<String>.from(taskDoc.data()['taskMembers'] ?? []);
        final isMember = taskMembers.contains(email);

        if (isMember) {
          final submissionDoc = await taskDoc.reference
              .collection('submissions')
              .doc(email)
              .get();

          final submission = submissionDoc.data();

          // Ambil className dari dokumen kelas
          final classDoc = await _firestore
              .collection('classes')
              .doc(taskDoc.data()['classCode'])
              .get();

          tasks.add({
            'id': taskDoc.id,
            'classCode': taskDoc.data()['classCode'],
            'className': classDoc.data()?['className'],
            ...taskDoc.data(),
            'submission': submission ??
                {
                  'taskId': taskDoc.id,
                  'email': email,
                  'score': null,
                  'gradedAt': null,
                  'submittedAt': null,
                  'attachmentUrl': null,
                  'feedback': null,
                }
          });
        }
      }

      return tasks;
    });
  }

  Future<Map<String, dynamic>?> getSubmissionByEmailAndId({
    required String email,
    required String taskId,
  }) async {
    try {
      final taskDocs = await _firestore.collectionGroup('tasks').get();
      final taskDoc = taskDocs.docs.firstWhere(
        (doc) => doc.id == taskId,
        orElse: () => throw Exception('Tugas tidak ditemukan'),
      );

      final submissionDoc =
          await taskDoc.reference.collection('submissions').doc(email).get();

      if (!submissionDoc.exists) {
        return null;
      }

      final userDoc = await _firestore.collection('users').doc(email).get();
      final username = userDoc.data()?['username'];

      return {
        'username': username,
        ...submissionDoc.data()!,
      };
    } catch (e) {
      throw Exception('Gagal mengambil submission: $e');
    }
  }

  Future<void> updateSubmissionEvaluation({
    required String taskId,
    required String email,
    required int score,
    required String feedback,
  }) async {
    try {
      final taskDocs = await _firestore.collectionGroup('tasks').get();
      final taskDoc = taskDocs.docs.firstWhere(
        (doc) => doc.id == taskId,
        orElse: () => throw Exception('Tugas tidak ditemukan'),
      );

      final submissionRef =
          taskDoc.reference.collection('submissions').doc(email);

      await submissionRef.update({
        'score': score,
        'feedback': feedback,
        'gradedAt': FieldValue.serverTimestamp(),
      });

      final classDoc = await _firestore
          .collection('classes')
          .doc(taskDoc.data()['classCode'])
          .get();

      final taskName = taskDoc.data()['taskName'];
      final className = classDoc.data()?['className'];

      await _createAndSendNotification(
        type: 'Tugas Dinilai',
        message: '$taskName di kelas $className telah dinilai',
        recipients: [email],
      );
    } catch (e) {
      throw Exception('Gagal memperbarui penilaian: $e');
    }
  }

  Future<void> cancelSubmissionEvaluation({
    required String taskId,
    required String email,
  }) async {
    try {
      final taskDocs = await _firestore.collectionGroup('tasks').get();
      final taskDoc = taskDocs.docs.firstWhere(
        (doc) => doc.id == taskId,
        orElse: () => throw Exception('Tugas tidak ditemukan'),
      );

      final submissionRef =
          taskDoc.reference.collection('submissions').doc(email);

      await submissionRef.update({
        'score': null,
        'feedback': null,
        'gradedAt': null,
      });

      final classDoc = await _firestore
          .collection('classes')
          .doc(taskDoc.data()['classCode'])
          .get();

      final taskName = taskDoc.data()['taskName'];
      final className = classDoc.data()?['className'];

      await _createAndSendNotification(
        type: 'Penilaian Dibatalkan',
        message:
            'Penilaian untuk $taskName di kelas $className telah dibatalkan',
        recipients: [email],
      );
    } catch (e) {
      throw Exception('Gagal membatalkan penilaian: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getTasks({required String classCode}) {
    return _firestore
        .collection('classes')
        .doc(classCode)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((tasksSnapshot) {
      return tasksSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    }).handleError((e) {
      throw Exception('Gagal mengambil daftar tugas: $e');
    });
  }

  Future<bool> checkTaskNameExists({
    required String classCode,
    required String taskName,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('classes')
          .doc(classCode)
          .collection('tasks')
          .where('taskName', isEqualTo: taskName)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Gagal memeriksa nama tugas: $e');
    }
  }

  Future<void> updateTask({
    required String taskId,
    required String classCode,
    required String taskName,
    required String description,
    required DateTime taskDeadline,
    required DateTime taskCloseDeadline,
    required String? attachmentTaskUrl,
    required List<String> taskMembers,
  }) async {
    try {
      final taskData = {
        'taskName': taskName,
        'taskDeadline': taskDeadline,
        'taskCloseDeadline': taskCloseDeadline,
        'description': description,
        'attachmentTaskUrl': attachmentTaskUrl,
        'taskMembers': taskMembers,
      };

      await _firestore
          .collection('classes')
          .doc(classCode)
          .collection('tasks')
          .doc(taskId)
          .update(taskData);

      final classDoc =
          await _firestore.collection('classes').doc(classCode).get();
      final className = classDoc['className'];
      final members =
          List<Map<String, dynamic>>.from(classDoc['members'] ?? []);

      List<String> recipientEmails =
          members.map<String>((m) => m['email'].toString()).toList();

      await _createAndSendNotification(
        type: 'Tugas Diperbarui',
        message: '$taskName telah diperbarui di kelas $className',
        recipients: recipientEmails,
      );
    } catch (e) {
      throw Exception('Gagal memperbarui tugas: $e');
    }
  }

  Future<void> deleteTask({
    required String classCode,
    required String taskId,
  }) async {
    try {
      // Ambil detail tugas sebelum menghapus
      final taskDoc = await _firestore
          .collection('classes')
          .doc(classCode)
          .collection('tasks')
          .doc(taskId)
          .get();

      final taskName = taskDoc['taskName'];

      // Hapus semua pengumpulan terkait tugas
      final submissionsCollection = taskDoc.reference.collection('submissions');
      final submissionsSnapshot = await submissionsCollection.get();
      for (var submissionDoc in submissionsSnapshot.docs) {
        await submissionDoc.reference.delete();
      }

      // Hapus tugas
      await _firestore
          .collection('classes')
          .doc(classCode)
          .collection('tasks')
          .doc(taskId)
          .delete();

      final classDoc =
          await _firestore.collection('classes').doc(classCode).get();
      final className = classDoc['className'];
      final members =
          List<Map<String, dynamic>>.from(classDoc['members'] ?? []);

      List<String> recipientEmails =
          members.map<String>((m) => m['email'].toString()).toList();

      await _createAndSendNotification(
        type: 'Tugas Dihapus',
        message: '$taskName telah dihapus dari kelas $className',
        recipients: recipientEmails,
      );
    } catch (e) {
      throw Exception('Gagal menghapus tugas: $e');
    }
  }

  Future<void> submitTask({
    required String classCode,
    required String taskId,
    required String email,
    required String? attachmentUrl,
  }) async {
    try {
      final submissionData = {
        'taskId': taskId,
        'email': email,
        'submittedAt': FieldValue.serverTimestamp(),
        'attachmentUrl': attachmentUrl,
        'score': null,
        'gradedAt': null,
        'feedback': null,
      };

      // Buat dokumen submission baru saat submit
      await _firestore
          .collection('classes')
          .doc(classCode)
          .collection('tasks')
          .doc(taskId)
          .collection('submissions')
          .doc(email)
          .set(submissionData);

      final taskDoc = await _firestore
          .collection('classes')
          .doc(classCode)
          .collection('tasks')
          .doc(taskId)
          .get();

      final classDoc =
          await _firestore.collection('classes').doc(classCode).get();
      final className = classDoc['className'];
      final taskName = taskDoc['taskName'];
      final members =
          List<Map<String, dynamic>>.from(classDoc['members'] ?? []);

      List<String> recipientEmails = members
          .where((m) => m['role'] == 'Guru')
          .map<String>((m) => m['email'].toString())
          .toList();

      await _createAndSendNotification(
        type: 'Tugas Dikumpulkan',
        message: '$email telah mengumpulkan $taskName di kelas $className',
        recipients: recipientEmails,
      );
    } catch (e) {
      throw Exception('Gagal mengumpulkan tugas: $e');
    }
  }

  Future<void> undoSubmission({
    required String classCode,
    required String taskId,
    required String email,
  }) async {
    try {
      // Hapus dokumen submission saat membatalkan
      await _firestore
          .collection('classes')
          .doc(classCode)
          .collection('tasks')
          .doc(taskId)
          .collection('submissions')
          .doc(email)
          .delete();
    } catch (e) {
      throw Exception('Gagal menghapus lampiran tugas: $e');
    }
  }

  Future<Map<String, dynamic>> getTaskDetails({
    required String classCode,
    required String taskId,
  }) async {
    final snapshot = await _firestore
        .collection('classes')
        .doc(classCode)
        .collection('tasks')
        .doc(taskId)
        .get();
    return snapshot.data() ?? {};
  }

  Stream<List<Map<String, dynamic>>> getSubmittedTaskMembers({
    required String classCode,
    required String taskId,
  }) {
    return _firestore
        .collection('classes')
        .doc(classCode)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .snapshots()
        .asyncMap((submissionSnapshot) async {
      List<Map<String, dynamic>> submittedMembers = [];

      for (var doc in submissionSnapshot.docs) {
        final submissionData = doc.data();

        final userDoc = await _firestore
            .collection('users')
            .doc(submissionData['email'])
            .get();

        if (userDoc.exists) {
          submittedMembers.add({
            'email': submissionData['email'],
            'username': userDoc.data()?['username'] ?? '',
            'submittedAt': submissionData['submittedAt'],
            'score': submissionData['score'],
            'gradedAt': submissionData['gradedAt'],
            'feedback': submissionData['feedback'],
            'attachmentUrl': submissionData['attachmentUrl'],
          });
        }
      }

      return submittedMembers;
    });
  }

  Stream<List<Map<String, dynamic>>> getNotSubmittedTaskMembers({
    required String classCode,
    required String taskId,
  }) {
    return _firestore
        .collection('classes')
        .doc(classCode)
        .collection('tasks')
        .doc(taskId)
        .snapshots()
        .asyncMap((taskSnapshot) async {
      final submissionSnapshot =
          await taskSnapshot.reference.collection('submissions').get();

      final taskMembers =
          List<String>.from(taskSnapshot.data()?['taskMembers'] ?? []);

      final submittedEmails = submissionSnapshot.docs
          .map((doc) => doc.data()['email'] as String)
          .toList();

      final notSubmittedEmails = taskMembers
          .where((email) => !submittedEmails.contains(email))
          .toList();

      List<Map<String, dynamic>> notSubmittedMembers = [];
      for (var email in notSubmittedEmails) {
        final userDoc = await _firestore.collection('users').doc(email).get();

        if (userDoc.exists) {
          notSubmittedMembers.add({
            'email': email,
            'username': userDoc.data()?['username'] ?? '',
          });
        }
      }

      return notSubmittedMembers;
    });
  }

  Future<void> checkAndSendTaskReminders() async {
    try {
      final now = DateTime.now();
      final tomorrow = now.add(Duration(days: 1));

      // Ambil semua kelas terlebih dahulu
      final classesSnapshot = await _firestore.collection('classes').get();

      for (var classDoc in classesSnapshot.docs) {
        // Ambil tugas untuk setiap kelas
        final tasksSnapshot = await classDoc.reference
            .collection('tasks')
            .where('taskDeadline', isGreaterThan: Timestamp.fromDate(now))
            .where('taskDeadline', isLessThan: Timestamp.fromDate(tomorrow))
            .get();

        for (var taskDoc in tasksSnapshot.docs) {
          final taskData = taskDoc.data();
          final taskName = taskData['taskName'] as String;
          final taskDeadline = (taskData['taskDeadline'] as Timestamp).toDate();
          final taskMembers = List<String>.from(taskData['taskMembers'] ?? []);

          // Ambil data submission yang sudah ada
          final submissionSnapshot =
              await taskDoc.reference.collection('submissions').get();
          final submittedEmails = submissionSnapshot.docs
              .map((doc) => doc.data()['email'] as String)
              .toList();

          // Filter member yang belum submit
          final notSubmittedEmails = taskMembers
              .where((email) => !submittedEmails.contains(email))
              .toList();

          if (notSubmittedEmails.isNotEmpty) {
            final className = classDoc.data()['className'] as String;

            for (var email in notSubmittedEmails) {
              // Buat notifikasi
              await _createAndSendNotification(
                type: 'Pengingat Tugas',
                message:
                    '$taskName di kelas $className akan berakhir dalam ${_formatDuration(taskDeadline.difference(now))}',
                recipients: [email],
              );
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Gagal mengirim pengingat tugas: $e');
    }
  }

  // ===== Notification Functions =====

  Stream<List<Map<String, dynamic>>> getAllNotifications(
      {required bool ascending, required String email}) {
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: !ascending)
        .snapshots()
        .asyncMap((snapshot) async {
      final notifications = List<Map<String, dynamic>>.from(
          snapshot.docs.map((doc) => doc.data()).toList());

      return notifications.where((doc) {
        List<dynamic>? recipients = doc['recipients'] as List<dynamic>?;
        return recipients?.contains(email) ?? false;
      }).toList();
    });
  }

  Future<void> _createAndSendNotification({
    required String type,
    required String message,
    required List<String> recipients,
  }) async {
    String notificationId = _firestore.collection('notifications').doc().id;
    final notificationData = {
      'id': notificationId,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
      'recipients': recipients,
      'message': message,
      'isRead': false,
    };

    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .set(notificationData);

    List<String> fcmTokens = await _getFcmTokensForRecipients(recipients);

    if (fcmTokens.isNotEmpty) {
      await _sendNotification(
        title: type,
        body: message,
        recipients: fcmTokens,
      );
    }
  }

  Future<List<String>> _getFcmTokensForRecipients(
      List<String> recipients) async {
    List<String> fcmTokens = [];
    for (String email in recipients) {
      fcmTokens.addAll(await _getFcmTokens(email));
    }
    return fcmTokens;
  }

  Future<void> _sendNotification({
    required String title,
    required String body,
    required List<String> recipients,
  }) async {
    const String projectId = 'tugaskuappid';
    final String fcmUrl =
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    for (String recipient in recipients) {
      final String accessToken = await _getAccessToken();

      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "message": {
            "token": recipient,
            "notification": {"title": title, "body": body},
            "android": {"priority": "high"}
          }
        }),
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          await _removeInvalidToken(token: recipient);
          continue;
        }
        throw Exception(
            'FCM request failed with status: ${response.statusCode}, body: ${response.body}');
      }
    }
  }

  Future<void> _removeInvalidToken({required String token}) async {
    QuerySnapshot userDocs = await _firestore
        .collection('users')
        .where('fcmTokens', arrayContains: token)
        .get();

    for (var doc in userDocs.docs) {
      await _firestore.collection('users').doc(doc.id).update({
        'fcmTokens': FieldValue.arrayRemove([token])
      });
    }
  }

  Future<String> _getAccessToken() async {
    final serviceAccountJson = await rootBundle.loadString(
        'assets/tugaskuappid-firebase-adminsdk-axcfu-0645dd0904.json');
    final credentials =
        ServiceAccountCredentials.fromJson(json.decode(serviceAccountJson));
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await clientViaServiceAccount(credentials, scopes);
    final accessToken = client.credentials.accessToken.data;
    client.close();
    return accessToken;
  }

  // ===== Utility Functions =====

  Future<List<String>> _getFcmTokens(String email) async {
    final userDoc = await _firestore.collection('users').doc(email).get();
    return List<String>.from(userDoc.data()?['fcmTokens'] ?? []);
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 1) {
      return '${duration.inHours} jam';
    } else if (duration.inMinutes > 1) {
      return '${duration.inMinutes} menit';
    } else {
      return '${duration.inSeconds} detik';
    }
  }
}
