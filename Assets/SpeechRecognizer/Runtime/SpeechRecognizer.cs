using System;
using System.Runtime.InteropServices;

namespace SpeechRecognizerPlugin
{
    public class MonoPInvokeCallbackAttribute : Attribute
    {
        private Type type;
        public MonoPInvokeCallbackAttribute(Type t)
        {
            type = t;
        }
    }


    public class SpeechRecognizer
    {

        public enum AuthorizationStatus
        {
            NotDetermined = 0,
            Denied = 1,
            Restricted = 2,
            Authorized = 3,
        }

        public delegate void RequestCallback(int status);
        public delegate void ResultCallback(string result);


        public static Action<AuthorizationStatus> OnAuthorization = null;
        public static Action<string> OnResult = null;
        public static bool IsRunning { get; private set; }

        public static void RequestAuthorization()
        {
            _unitySpeechRecognizerRequestAuthorization(_OnAuthorization);
        }

        public static AuthorizationStatus GetAuthorizationStatus()
        {
            int status = _unitySpeechRecognizerAuthorizationStatus();
            return (AuthorizationStatus)status;
        }

        public static void SetLocale(string locale)
        {
            _unitySpeechRecognizerSetLocale(locale);
        }

        public static void Start()
        {
            IsRunning = true;
            _unitySpeechRecognizerStart(_OnResult);
        }

        public static void Stop()
        {
            IsRunning = false;
            _unitySpeechRecognizerStop();
        }

        [MonoPInvokeCallback(typeof(RequestCallback))]
        private static void _OnAuthorization(int status)
        {
            UnityEngine.Debug.LogFormat("_OnAuthorization: {0}", status);
            if (OnAuthorization != null)
            {
                OnAuthorization((AuthorizationStatus)status);
            }
        }

        [MonoPInvokeCallback(typeof(RequestCallback))]
        private static void _OnResult(string result)
        {
            UnityEngine.Debug.LogFormat("_OnResult: {0}", result);
            if (OnResult != null)
            {
                OnResult(result);
            }
        }

        #region DllImports

#if UNITY_IPHONE && !UNITY_EDITOR
        [DllImport("__Internal")]
        private static extern void _unitySpeechRecognizerRequestAuthorization(RequestCallback callback);
        [DllImport("__Internal")]
        private static extern int _unitySpeechRecognizerAuthorizationStatus();
        [DllImport("__Internal")]
        private static extern void _unitySpeechRecognizerSetLocale(string locale);
        [DllImport("__Internal")]
        private static extern void _unitySpeechRecognizerStart(ResultCallback callback);
        [DllImport("__Internal")]
        private static extern void _unitySpeechRecognizerStop();
#else
        private static void _unitySpeechRecognizerRequestAuthorization(RequestCallback callback) { UnityEngine.Debug.Log("SpeechRecognizer RequestAuth"); }
        private static int _unitySpeechRecognizerAuthorizationStatus() { return 0; }
        private static void _unitySpeechRecognizerSetLocale(string locale) { UnityEngine.Debug.LogFormat("SpeechRecognizer SetLocale: {0}", locale); }
        private static void _unitySpeechRecognizerStart(ResultCallback callback) { UnityEngine.Debug.Log("SpeechRecognizer Start"); }
        private static void _unitySpeechRecognizerStop() { UnityEngine.Debug.Log("SpeechRecognizer Stop"); }
#endif

        #endregion // DllImport
    }
}

