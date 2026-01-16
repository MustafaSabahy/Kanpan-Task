/// App configuration - handles API tokens and environment variables
class AppConfig {
  AppConfig._();

  /// Get Todoist API token
  /// 
  /// **HOW TO GET YOUR TOKEN:**
  /// 1. Go to: https://developer.todoist.com/appconsole.html
  /// 2. Create a new app or use an existing one
  /// 3. Copy the API token
  /// 4. Replace 'YOUR_TODOIST_API_TOKEN_HERE' below with your actual token
  /// 
  /// **IMPORTANT:** Never commit your actual token to version control!
  /// This file is already in .gitignore for security.
  static String get todoistApiToken {
    // 👇 REPLACE THIS WITH YOUR ACTUAL TODOIST API TOKEN 👇
    const token = '5dc0b6e5c817a096d55634846fa86a0ec0c873dd';
    // 👆 Get your token from: https://developer.todoist.com/appconsole.html 👆
    
    return token;
  }
  
  /// Check if a valid token is configured
  static bool get hasValidToken {
    final token = todoistApiToken;
    return token.isNotEmpty && 
           token != '1230b6c090cb7808bda113bb3ab8cb1ce84ef6a3' &&
           token.length > 10; // Basic validation
  }
}
