component {

    this.name = "commandbox-semantic-release";
    this.autoMapModels = false;

    function configure() {
        settings = {
            "versionPrefix" = "v",
            "targetBranch" = "master",
            "plugins" = {
                "VerifyConditions" = "TravisConditionsVerifier@commandbox-semantic-release",
                "GetLastRelease"   = "ForgeBoxReleaseFetcher@commandbox-semantic-release",
                "AnalyzeCommits"   = "DefaultCommitAnalyzer@commandbox-semantic-release",
                "VerifyRelease"    = "NullReleaseVerifier@commandbox-semantic-release",
                "PublishRelease"   = "ForgeBoxReleasePublisher@commandbox-semantic-release",
                "GenerateNotes"    = "GitHubMarkdownNotesGenerator@commandbox-semantic-release",
                "PublicizeRelease" = "GitHubReleasePublicizer@commandbox-semantic-release"
            },
            "pluginOptions" = {
                "VerifyConditions" = {
                    "buildTimeout" = 600, // seconds
                    "pollingInterval" = 5 // seconds
                }
            }
        };

        binder.map( "TravisConditionsVerifier@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.TravisConditionsVerifier" );
        binder.map( "ForgeBoxReleaseFetcher@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.ForgeBoxReleaseFetcher" );
        binder.map( "DefaultCommitAnalyzer@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.DefaultCommitAnalyzer" );
        binder.map( "NullReleaseVerifier@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.NullReleaseVerifier" );
        binder.map( "ForgeBoxReleasePublisher@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.ForgeBoxReleasePublisher" );
        binder.map( "GitHubMarkdownNotesGenerator@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.GitHubMarkdownNotesGenerator" );
        binder.map( "GitHubReleasePublicizer@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.GitHubReleasePublicizer" );

        binder.map( "ConventionalChangelogParser@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.ConventionalChangelogParser" );
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
