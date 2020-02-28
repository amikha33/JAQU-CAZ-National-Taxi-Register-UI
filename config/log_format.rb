# Modified Formatter class to remove IPs from logging - CAZSM3
class Formatter
    Format = "%s\n"

    # https://www.oreilly.com/library/view/regular-expressions-cookbook/9780596802837/ch07s16.html
    IPRegex = /\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b/
    FilteredString = '[REDACTED]'

    def call(severity, time, progname, msg)
        Format % [msg2str(filter_ip(msg))]
    end

    private

    # Parse log messages and handle exceptions.
    def msg2str(msg)
        case msg
        when ::String
            msg
        when ::Exception
        "#{ msg.message } (#{ msg.class })\n" <<
            (msg.backtrace || []).join("\n")
        else
            msg.inspect
        end
    end

    # If log string contains IP address then replace it with custom string
    def filter_ip(msg)   
      msg.gsub(IPRegex, FilteredString)
    end
end