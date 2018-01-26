component {

    this.name = "commandbox-semantic-release";
    this.autoMapModels = false;

    function configure() {
        settings = {
            "versionPrefix" = "v",
            "changelogFileName" = "CHANGELOG.md",
            "targetBranch" = "master",
            "buildCommitMessage" = "__SEMANTIC RELEASE VERSION UPDATE__",
            "plugins" = {
                "VerifyConditions" = "TravisConditionsVerifier@commandbox-semantic-release",
                "ReleaseFetcher"   = "ForgeBoxReleaseFetcher@commandbox-semantic-release",
                "CommitsRetriever" = "DefaultCommitsRetriever@commandbox-semantic-release",
                "CommitParser"     = "ConventionalChangelogParser@commandbox-semantic-release",
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
        binder.map( "DefaultCommitsRetriever@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.DefaultCommitsRetriever" );
        binder.map( "ConventionalChangelogParser@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.ConventionalChangelogParser" );
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

    }

    function onLoad() {
        binder.map( "VerifyConditions@commandbox-semantic-release" )
            .toDSL( settings.plugins.VerifyConditions );
        binder.map( "ReleaseFetcher@commandbox-semantic-release" )
            .toDSL( settings.plugins.ReleaseFetcher );
        binder.map( "CommitsRetriever@commandbox-semantic-release" )
            .toDSL( settings.plugins.CommitsRetriever );
        binder.map( "CommitParser@commandbox-semantic-release" )
            .toDSL( settings.plugins.CommitParser );
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
