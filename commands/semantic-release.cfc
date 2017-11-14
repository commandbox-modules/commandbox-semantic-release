component {

    property name="VerifyConditions" inject="VerifyConditions@commandbox-semantic-release";
    property name="GetLastRelease"   inject="GetLastRelease@commandbox-semantic-release";
    property name="AnalyzeCommits"   inject="AnalyzeCommits@commandbox-semantic-release";
    property name="VerifyRelease"    inject="VerifyRelease@commandbox-semantic-release";
    property name="PublishRelease"   inject="PublishRelease@commandbox-semantic-release";
    property name="GenerateNotes"    inject="GenerateNotes@commandbox-semantic-release";
    property name="PublicizeRelease" inject="PublicizeRelease@commandbox-semantic-release";

    function run() {
        VerifyConditions.run();
        GetLastRelease.run();
        AnalyzeCommits.run();
        VerifyRelease.run();
        PublishRelease.run();
        GenerateNotes.run();
        PublicizeRelease.run();
    }

}
