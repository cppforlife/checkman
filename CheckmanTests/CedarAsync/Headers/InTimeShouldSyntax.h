#import "AsyncActualValue.h"

namespace CedarAsync {
    template<typename T>
    struct InTimeMarker {
        T(^actualExpression)(void);
        const char *fileName;
        int lineNumber;
    };

    template<typename T>
    const AsyncActualValue<T> operator,(const InTimeMarker<T> & marker, const Cedar::Matchers::ActualValueMarker & _) {
        return AsyncActualValue<T>(marker.fileName, marker.lineNumber, marker.actualExpression);
    }

    template<typename T>
    const AsyncActualValueMatchProxy<T> operator,(const AsyncActualValue<T> & actualValue, bool negate) {
        return negate ? actualValue.to_not : actualValue.to;
    }

    template<typename T, typename MatcherType>
    void operator,(const AsyncActualValueMatchProxy<T> & matchProxy, const MatcherType & matcher) {
        matchProxy(matcher);
    }
}

#ifndef CEDAR_ASYNC_DISALLOW_IN_TIME
#define in_time(x) (InTimeMarker<typeof(x)>){^{return x;}, __FILE__, __LINE__}
#endif
