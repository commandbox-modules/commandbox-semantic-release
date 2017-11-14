component {

    this.name = "commandbox-semantic-release";
    this.autoMapModels = false;

    function configure() {
        settings = {
            plugins = {
                "VerifyConditions" = "TravisConditionsVerifier@commandbox-semantic-release",
                "GetLastRelease"   = "ForgeBoxReleaseFetcher@commandbox-semantic-release",
                "AnalyzeCommits"   = "DefaultCommitAnalyzer@commandbox-semantic-release",
                "VerifyRelease"    = "DefaultReleaseVerifier@commandbox-semantic-release",
                "PublishRelease"   = "ForgeBoxReleasePublisher@commandbox-semantic-release",
                "GenerateNotes"    = "DefaultNotesGenerator@commandbox-semantic-release",
                "PublicizeRelease" = "GitHubReleasePublicizer@commandbox-semantic-release"
            }
        };

        binder.map( "TravisConditionsVerifier@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.TravisConditionsVerifier" );
        binder.map( "ForgeBoxReleaseFetcher@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.ForgeBoxReleaseFetcher" );
        binder.map( "DefaultCommitAnalyzer@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.DefaultCommitAnalyzer" );
        binder.map( "DefaultReleaseVerifier@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.DefaultReleaseVerifier" );
        binder.map( "ForgeBoxReleasePublisher@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.ForgeBoxReleasePublisher" );
        binder.map( "DefaultNotesGenerator@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.DefaultNotesGenerator" );
        binder.map( "GitHubReleasePublicizer@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.GitHubReleasePublicizer" );
    }

    function onLoad() {
        binder.map( "VerifyConditions@commandbox-semantic-release" )
            .toDSL( settings.plugins.VerifyConditions );
        binder.map( "GetLastRelease@commandbox-semantic-release" )
            .toDSL( settings.plugins.GetLastRelease );
        binder.map( "AnalyzeCommits@commandbox-semantic-release" )
            .toDSL( settings.plugins.AnalyzeCommits );
        binder.map( "VerifyRelease@commandbox-semantic-release" )
            .toDSL( settings.plugins.VerifyRelease );
        binder.map( "PublishRelease@commandbox-semantic-release" )
            .toDSL( settings.plugins.PublishRelease );
        binder.map( "GenerateNotes@commandbox-semantic-release" )
            .toDSL( settings.plugins.GenerateNotes );
        binder.map( "PublicizeRelease@commandbox-semantic-release" )
            .toDSL( settings.plugins.PublicizeRelease );
    }

}
