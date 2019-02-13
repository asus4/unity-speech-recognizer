using System.IO;
using UnityEngine;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;

namespace SpeechRecognizerPlugin.Editor
{


    public static class PostProcessBuildIOS
    {

        [PostProcessBuild]
        public static void ChangeXcodePlist(BuildTarget buildTarget, string pathToBuiltProject)
        {
            if (buildTarget != BuildTarget.iOS)
            {
                return;
            }

            EditInfoPlist(Path.Combine(pathToBuiltProject, "Info.plist"));
            AddFrameworks(PBXProject.GetPBXProjectPath(pathToBuiltProject));
        }

        static void EditInfoPlist(string plistPath)
        {
            PlistDocument plist = new PlistDocument();
            plist.ReadFromString(File.ReadAllText(plistPath));

            // Get root
            PlistElementDict rootDict = plist.root;
            rootDict.SetString("NSMicrophoneUsageDescription", "To use speech recognization.");
            rootDict.SetString("NSSpeechRecognitionUsageDescription", "To use speech recognization.");

            // Save updated
            File.WriteAllText(plistPath, plist.WriteToString());
        }

        static void AddFrameworks(string projectPath)
        {
            PBXProject project = new PBXProject();
            project.ReadFromString(File.ReadAllText(projectPath));
            string targetGUID = project.TargetGuidByName(PBXProject.GetUnityTargetName());

            project.AddFrameworkToProject(targetGUID, "Speech.framework", false);

            File.WriteAllText(projectPath, project.WriteToString());
        }
    }
}