using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace SpeechRecognizerPlugin
{
    public class SpeechRecognizerSample : MonoBehaviour
    {
        [SerializeField] Text resultText = null;
        [SerializeField] Text buttonLabel = null;
        [SerializeField] string locale = "en-US";

        string result = null;

        void OnEnable()
        {
            SpeechRecognizer.OnAuthorization += OnAuthorization;
            SpeechRecognizer.OnResult += OnResult;
        }

        void OnDisable()
        {
            SpeechRecognizer.OnAuthorization -= OnAuthorization;
            SpeechRecognizer.OnResult -= OnResult;
        }

        void Start()
        {
            SpeechRecognizer.SetLocale(locale);
            SpeechRecognizer.RequestAuthorization();
        }

        void Update()
        {
            if (!string.IsNullOrEmpty(result))
            {
                resultText.text = result;
                result = null;
            }
        }

        public void OnClickStartButton()
        {
            // Invoked from UI

            if (SpeechRecognizer.IsRunning)
            {
                SpeechRecognizer.Stop();
                buttonLabel.text = "Start";
            }
            else
            {
                SpeechRecognizer.Start();
                buttonLabel.text = "Stop";
            }
        }

        void OnAuthorization(SpeechRecognizer.AuthorizationStatus status)
        {
            Debug.LogFormat("status : {0}", status);
        }

        void OnResult(string result)
        {
            // this comes from the different thread
            this.result = result;
        }
    }
}

