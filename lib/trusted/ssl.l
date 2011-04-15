
import "ssl";

namespace Util is
    use System.String;

    class OpenSSL is
        native char ptr MD5(char ptr data, int len, char ptr result);
        char ptr MD5(char ptr data, int len) is        
        si

        static char[] MD5(char[] data) is
            var result = new char[16];

            MD5(data.address, data.length, result.address);

            return result;
        si

        static char[] MD5(String s) is            
            var result = new char[16];

            MD5(s.toCString(), s.Length, result.address);

            return result;
        si         
    si
si