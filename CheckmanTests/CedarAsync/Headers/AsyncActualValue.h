#import "Timing.h"

namespace CedarAsync {
    template<typename T> class AsyncActualValue;

#pragma mark class AsyncActualValueMatchProxy
    template<typename T>
    class AsyncActualValueMatchProxy {
    private:
        template<typename U>
        AsyncActualValueMatchProxy(const AsyncActualValueMatchProxy<U> &);
        template<typename U>
        AsyncActualValueMatchProxy & operator=(const AsyncActualValueMatchProxy<U> &);

    public:
        explicit AsyncActualValueMatchProxy(const AsyncActualValue<T> &, bool negate = false);
        AsyncActualValueMatchProxy();

        template<typename MatcherType> void operator()(const MatcherType &) const;
        AsyncActualValueMatchProxy<T> negate() const;

    private:
        const AsyncActualValue<T> & actualValue_;
        bool negate_;
    };

    template<typename T>
    AsyncActualValueMatchProxy<T>::AsyncActualValueMatchProxy(const AsyncActualValue<T> & actualValue, bool negate /*= false */)
    : actualValue_(actualValue), negate_(negate) {}

    template<typename T> template<typename MatcherType>
    void AsyncActualValueMatchProxy<T>::operator()(const MatcherType & matcher) const {
        actualValue_.execute_match(matcher, !negate_);
    }

    template<typename T>
    AsyncActualValueMatchProxy<T> AsyncActualValueMatchProxy<T>::negate() const {
        return AsyncActualValueMatchProxy<T>(actualValue_, !negate_);
    }

#pragma mark class AsyncActualValue
    template<typename T>
    class AsyncActualValue {
    private:
        template<typename U>
        AsyncActualValue(const AsyncActualValue<U> &);
        template<typename U>
        AsyncActualValue & operator=(const AsyncActualValue<U> &);

    public:
        typedef T(^ExpressionBlock)(void);
        explicit AsyncActualValue(const char *, int, const ExpressionBlock &);

        AsyncActualValueMatchProxy<T> to;
        AsyncActualValueMatchProxy<T> to_not;

    protected:
        template<typename MatcherType>
        void execute_match(const MatcherType &, bool) const;
        friend class AsyncActualValueMatchProxy<T>;

    private:
        const ExpressionBlock & expression_;
        std::string fileName_;
        int lineNumber_;
    };

    template<typename T>
    AsyncActualValue<T>::AsyncActualValue(const char *fileName, int lineNumber, const ExpressionBlock & expression)
    : fileName_(fileName), lineNumber_(lineNumber), expression_(expression), to(*this), to_not(*this, true) {}

    template<typename T> template<typename MatcherType>
    void AsyncActualValue<T>::execute_match(const MatcherType & matcher, bool positive) const {
        id match = ^(BOOL timedOut){
            const T & value = ((T(^)(void))expression_)();
            bool matches = matcher.matches(value);

            // Stop immediately as soon as positive match is encountered
            if (positive && matches) return CDRATimingPollStop;

            if (timedOut) {
                // Wait until the end to make sure negative match remains negative
                if (!positive && !matches) return CDRATimingPollStop;

                NSString *message = positive ?
                    matcher.failure_message_for(value) : matcher.negative_failure_message_for(value);
                Cedar::Matchers::CDR_fail(fileName_.c_str(), lineNumber_, message);
            }
            return CDRATimingPollContinue;
        };

        [CDRATiming pollRunLoop:match every:Timing::current_poll timeout:Timing::current_timeout];
    }
}
