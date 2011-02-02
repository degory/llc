
namespace Util is
  use System.String;
  use IO.Std;
  use IO.Writer;

  class Logger is
    public const int DEBUG = 0;
    public const int INFO = 1;
    public const int WARN = 2;
    public const int ERROR = 3;
    public const int FATAL = 4;

    static String[] level_name = { "DEBUG", "INFO", "WARN", "ERROR", "FATAL" };

    static int log_level = INFO;
    static Writer log_writer;

    static void log( int l, String m ) is
      if l >= log_level then
        LogWriter.println( "" + Time.NowInSeconds + " " + level_name[l] + ": " + m );
      fi
    si

    static void log( int l, char ptr m ) is
      if l >= log_level then
        LogWriter.println( "" + Time.NowInSeconds + " " + level_name[l] + ": " + m );
      fi
    si

    static get int LogLevel is
      return log_level;
    si

    static set int LogLevel = l is
      log_level = l;
    si

    static get Writer LogWriter is
      if log_writer == null then
        log_writer = Std.err;
      fi
      return log_writer;
    si

    static set Writer LogWriter = w is
      log_writer = w;
    si

  si
si