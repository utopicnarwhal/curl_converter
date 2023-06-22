import 'package:args/args.dart';
import 'package:equatable/equatable.dart';

/// A representation of a cURL command in Dart.
///
/// The Curl class provides methods for parsing a cURL command string
/// and formatting a Curl object back into a cURL command.
class Curl extends Equatable {
  /// Specifies the HTTP request method (e.g., GET, POST, PUT, DELETE).
  final String method;

  /// Specifies the HTTP request URL
  final Uri uri;

  /// Adds custom HTTP headers to the request.
  final Map<String, String>? headers;

  /// Sends data as the request body (typically used with POST requests).
  final String? data;

  /// Sends cookies with the request.
  final String? cookie;

  /// Specifies the username and password for HTTP basic authentication.
  final String? user;

  /// Sets the Referer header for the request.
  final String? referer;

  /// Sets the User-Agent header for the request.
  final String? userAgent;

  /// Sends data as a multipart/form-data request.
  final bool form;

  /// Allows insecure SSL connections.
  final bool insecure;

  /// Follows HTTP redirects.
  final bool location;

  /// Constructs a new Curl object with the specified parameters.
  /// 
  /// The uri parameter is required, while the remaining parameters are optional.
  Curl({
    required this.uri,
    this.method = 'GET',
    this.headers,
    this.data,
    this.cookie,
    this.user,
    this.referer,
    this.userAgent,
    this.form = false,
    this.insecure = false,
    this.location = false,
  });

  /// Parse [curlString] as a [Curl] class instance.
  ///
  /// Like [parse] except that this function returns `null` where a
  /// similar call to [parse] would throw a throwable.
  ///
  /// Example:
  /// ```dart
  /// print(Curl.tryParse('curl -X GET https://www.example.com/')); // Curl(method: 'GET', url: 'https://www.example.com/')
  /// print(Curl.tryParse('1f')); // null
  /// ```
  static Curl? tryParse(String curlString) {
    try {
      Curl.parse(curlString);
    } catch (_) {}
    return null;
  }

  /// Parse [curlString] as a [Curl] class instance.
  ///
  /// Example:
  /// ```dart
  /// print(Curl.tryParse('curl -X GET https://www.example.com/')); // Curl(method: 'GET', url: 'https://www.example.com/')
  /// print(Curl.tryParse('1f')); // [Exception] is thrown
  /// ```
  static Curl parse(String curlString) {
    final parser = ArgParser(allowTrailingOptions: true);

    // Define the expected options
    parser.addOption('request', abbr: 'X');
    parser.addMultiOption('header', abbr: 'H');
    parser.addOption('data', abbr: 'd');
    parser.addOption('cookie', abbr: 'b');
    parser.addOption('user', abbr: 'u');
    parser.addOption('referer', abbr: 'e');
    parser.addOption('user-agent', abbr: 'A');
    parser.addFlag('form', abbr: 'F');
    parser.addFlag('insecure', abbr: 'k');
    parser.addFlag('location', abbr: 'L');

    if (!curlString.startsWith('curl ')) {
      throw Exception("curlString doesn't start with 'curl '");
    }
    final result = parser.parse(
      curlString.replaceFirst('curl ', '').split(RegExp(r'\s+(?=([^\"]*\"[^\"]*\")*[^\"]*$)')),
    );

    final method = (result['request'] as String?)?.toUpperCase();

    // Extract the request headers
    Map<String, String>? headers;
    if (result['header'] != null) {
      final List<String> headersList = result['header'];
      if (headersList.isNotEmpty == true) {
        headers = <String, String>{};
        for (var headerString in headersList) {
          final splittedHeaderString = headerString.replaceAll('"', '').split(RegExp(r':\s*'));
          headers.addAll({splittedHeaderString[0]: splittedHeaderString[1]});
        }
      }
    }

    final String? data = result['data'];
    final String? cookie = result['cookie'];
    final String? user = result['user'];
    final String? referer = result['referer'];
    final String? userAgent = result['user-agent'];
    final bool form = result['form'] ?? false;
    final bool insecure = result['insecure'] ?? false;
    final bool location = result['location'] ?? false;

    // Extract the request URL
    final url = result.rest.isNotEmpty ? result.rest.first : null;
    if (url == null) {
      throw Exception('url is null');
    }
    final uri = Uri.parse(url);

    return Curl(
      method: method ?? 'GET',
      uri: uri,
      headers: headers,
      data: data,
      cookie: cookie,
      user: user,
      referer: referer,
      userAgent: userAgent,
      form: form,
      insecure: insecure,
      location: location,
    );
  }

  // Formatted cURL command
  String toCurlString() {
    var cmd = 'curl ';

    // Add the request method
    if (method != 'GET') {
      cmd += '-X $method ';
    }

    // Add the headers
    headers?.forEach((key, value) {
      cmd += '-H "$key: $value" ';
    });

    // Add the body
    if (data?.isNotEmpty == true) {
      cmd += '-d \'$data\' ';
    }
    // Add the cookie
    if (cookie?.isNotEmpty == true) {
      cmd += '-b \'$cookie\' ';
    }
    // Add the user
    if (user?.isNotEmpty == true) {
      cmd += '-u \'$user\' ';
    }
    // Add the referer
    if (referer?.isNotEmpty == true) {
      cmd += '-e \'$referer\' ';
    }
    // Add the user-agent
    if (userAgent?.isNotEmpty == true) {
      cmd += '-A \'$userAgent\' ';
    }
    // Add the form flag
    if (form) {
      cmd += '-F ';
    }
    // Add the insecure flag
    if (insecure) {
      cmd += '-k ';
    }
    // Add the location flag
    if (location) {
      cmd += '-L ';
    }

    // Add the URL
    cmd += '"${Uri.encodeFull(uri.toString())}"';

    return cmd.trim();
  }

  @override
  List<Object?> get props => [
        method,
        uri,
        headers,
        data,
        cookie,
        user,
        referer,
        userAgent,
        form,
        insecure,
        location,
      ];
}
