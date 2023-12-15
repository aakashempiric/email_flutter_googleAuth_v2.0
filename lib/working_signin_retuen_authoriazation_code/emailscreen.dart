import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/gmail/v1.dart' as gMail;
import 'package:intl/intl.dart';

class EmailScreen extends StatefulWidget {
  final String? displayName;

  EmailScreen(this.displayName, {Key? key}) : super(key: key);

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/gmail.readonly'],
  );

  gMail.GmailApi? _gmailApi;

  List<EmailDetails> _emailDetailsList = [];

  @override
  void initState() {
    super.initState();
    _initializeGmailApi();
  }

  Future<void> _initializeGmailApi() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
      await GoogleSignIn().signInSilently();

      if (googleSignInAccount != null && mounted) {
        final authHeaders = await googleSignInAccount.authHeaders;
        final authenticateClient = GoogleAuthClient(authHeaders);
        _gmailApi = gMail.GmailApi(authenticateClient);

        final String userEmail = googleSignInAccount.email!;
        gMail.ListMessagesResponse results =
        await _gmailApi!.users.messages.list(userEmail);
        List<gMail.Message>? messages = results.messages;


        if (messages != null && messages.isNotEmpty && mounted) {
          List<EmailDetails> fetchedEmailDetails = [];

          for (final message in messages) {
            final fullMessage = await _gmailApi!.users.messages
                .get(userEmail, message.id!, format: 'metadata');

            final sender = _getSender(fullMessage);
            final subject = _getSubject(fullMessage);
            final time = _getTime(fullMessage);

            fetchedEmailDetails.add(
              EmailDetails(
                sender: sender,
                subject: subject,
                time: time,
                //profileImg: profileImg ?? "",
              ),
            );
          }

          if (mounted) {
            setState(() {
              _emailDetailsList = fetchedEmailDetails;
            });
          }
        }
      }
    } catch (error) {
      if (mounted) {
        print('Error initializing Gmail API: $error');
      }
    }
  }

  String _getSender(gMail.Message fullMessage) {
    try {
      return fullMessage.payload?.headers
          ?.firstWhere((header) => header.name == 'From')
          .value ??
          'Unknown Sender';
    } catch (e) {
      return 'Unknown Sender';
    }
  }

  String _getSubject(gMail.Message fullMessage) {
    try {
      return fullMessage.payload?.headers
          ?.firstWhere((header) => header.name == 'Subject')
          .value ??
          'No Subject';
    } catch (e) {
      return 'No Subject';
    }
  }

  String _getTime(gMail.Message fullMessage) {
    try {
      final milliseconds = int.parse(fullMessage.internalDate!);
      final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
      return DateFormat.d().add_MMM().format(dateTime);
      // return DateFormat.MMMEd().add_jm().format(dateTime);
    } catch (e) {
      return 'Unknown Time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Email Page',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.lime.shade200,
      ),
      body: SingleChildScrollView(child: _buildEmailList()),
    );
  }

  Widget _buildEmailList() {
    return _emailDetailsList.isEmpty
        ? const Align(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    )
        : Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Hello, ${widget.displayName}!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: _emailDetailsList.length,
          itemBuilder: (context, index) {
            final emailDetails = _emailDetailsList[index];
            var splittedSenderName = emailDetails.sender.split('<');
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.black)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              'https://www.wildnatureimages.com/images/640/C6CT8748-Jasper-National-Park-Canada.jpg',
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                splittedSenderName.first,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                emailDetails.subject,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        emailDetails.time,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
            // return ListTile(
            //   title: Text(emailDetails.sender),
            //   subtitle: Text(emailDetails.subject),
            //   trailing: Text(emailDetails.time),
            // );
          },
        ),
      ],
    );
  }
}

class EmailDetails {
  final String sender;
  final String subject;
  final String time;

  //final String profileImg;

  EmailDetails({
    required this.sender,
    required this.subject,
    required this.time,
    //required this.profileImg,
  });
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
/*class _EmailScreenState extends State<EmailScreen> {
  gMail.GmailApi? _gmailApi;
  List<gMail.Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _initializeGmailApi();
  }

  Future<void> _initializeGmailApi() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await GoogleSignIn().signInSilently();

      if (googleSignInAccount != null && mounted) {
        final authHeaders = await googleSignInAccount.authHeaders;
        final authenticateClient = GoogleAuthClient(authHeaders);
        _gmailApi = gMail.GmailApi(authenticateClient);

        final String userEmail = googleSignInAccount.email!;
        gMail.ListMessagesResponse results =
            await _gmailApi!.users.messages.list(userEmail);
        List<gMail.Message>? messages = results.messages;

        if (messages != null && messages.isNotEmpty && mounted) {
          List<gMail.Message> fetchedMessages = [];
          for (gMail.Message message in messages) {
            gMail.Message fullMessage = await _gmailApi!.users.messages
                .get(userEmail, message.id!, format: 'metadata');
            fetchedMessages.add(fullMessage);
          }
          print(
              ":::::fetchedMessages:::${fetchedMessages.length}+:::::::+$fetchedMessages");

          if (mounted) {
            setState(() {
              _messages = fetchedMessages;
            });
          }
        }
      }
    } catch (error) {
      if (mounted) {
        print('Error initializing Gmail API: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Email Page',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.lime.shade200,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello, ${widget.displayName}!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (_messages.isEmpty)
              const CircularProgressIndicator()
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final subject = _messages[index]
                            .payload
                            ?.headers
                            ?.firstWhere((header) => header.name == 'Subject',
                                orElse: () => gMail.MessagePartHeader(
                                    name: '', value: 'No Subject'))
                            .value ??
                        'No Subject';

                    return ListTile(
                      title: Text(subject),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));

  }
}*/
