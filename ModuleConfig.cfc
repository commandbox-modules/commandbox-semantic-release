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
                "FetchLastRelease" = "ForgeBoxReleaseFetcher@commandbox-semantic-release",
                "RetrieveCommits"  = "JGitCommitsRetriever@commandbox-semantic-release",
                "ParseCommit"      = "ConventionalChangelogParser@commandbox-semantic-release",
                "FilterCommits"    = "DefaultCommitFilterer@commandbox-semantic-release",
                "AnalyzeCommits"   = "DefaultCommitAnalyzer@commandbox-semantic-release",
                "VerifyRelease"    = "NullReleaseVerifier@commandbox-semantic-release",
                "GenerateNotes"    = "GitHubMarkdownNotesGenerator@commandbox-semantic-release",
                "UpdateChangelog"  = "FileAppendChangelogUpdater@commandbox-semantic-release",
                "CommitArtifacts"  = "GitHubArtifactsCommitter@commandbox-semantic-release",
                "PublishRelease"   = "ForgeBoxReleasePublisher@commandbox-semantic-release",
                "PublicizeRelease" = "GitHubReleasePublicizer@commandbox-semantic-release"
            },
            "pluginOptions" = {
                "VerifyConditions" = {
                    "buildTimeout" = 600, // seconds
                    "pollingInterval" = 5 // seconds
                },
                "FetchLastRelease" = {},
                "RetrieveCommits" = {},
                "ParseCommit" = {},
                "FilterCommits" = {},
                "AnalyzeCommits" = {},
                "VerifyRelease" = {},
                "GenerateNotes" = {},
                "UpdateChangelog" = {},
                "CommitArtifacts" = {},
                "PublishRelease" = {},
                "PublicizeRelease" = {}
            }
        };

        binder.map( "TravisConditionsVerifier@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.TravisConditionsVerifier" );
        binder.map( "ForgeBoxReleaseFetcher@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.ForgeBoxReleaseFetcher" );
        binder.map( "JGitCommitsRetriever@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.JGitCommitsRetriever" );
        binder.map( "ConventionalChangelogParser@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.ConventionalChangelogParser" );
        binder.map( "DefaultCommitFilterer@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.DefaultCommitFilterer" );
        binder.map( "DefaultCommitAnalyzer@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.DefaultCommitAnalyzer" );
        binder.map( "NullReleaseVerifier@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.NullReleaseVerifier" );
        binder.map( "GitHubMarkdownNotesGenerator@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.GitHubMarkdownNotesGenerator" );
        binder.map( "FileAppendChangelogUpdater@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.FileAppendChangelogUpdater" );
        binder.map( "GitHubArtifactsCommitter@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.GitHubArtifactsCommitter" );
        binder.map( "ForgeBoxReleasePublisher@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.ForgeBoxReleasePublisher" );
        binder.map( "GitHubReleasePublicizer@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.GitHubReleasePublicizer" );
    }

    function onLoad() {
        binder.map( "VerifyConditions@commandbox-semantic-release" )
            .toDSL( settings.plugins.VerifyConditions );
        binder.map( "FetchLastRelease@commandbox-semantic-release" )
            .toDSL( settings.plugins.FetchLastRelease );
        binder.map( "RetrieveCommits@commandbox-semantic-release" )
            .toDSL( settings.plugins.RetrieveCommits );
        binder.map( "ParseCommit@commandbox-semantic-release" )
            .toDSL( settings.plugins.ParseCommit );
        binder.map( "FilterCommits@commandbox-semantic-release" )
            .toDSL( settings.plugins.FilterCommits );
        binder.map( "AnalyzeCommits@commandbox-semantic-release" )
            .toDSL( settings.plugins.AnalyzeCommits );
        binder.map( "VerifyRelease@commandbox-semantic-release" )
            .toDSL( settings.plugins.VerifyRelease );
        binder.map( "GenerateNotes@commandbox-semantic-release" )
            .toDSL( settings.plugins.GenerateNotes );
        binder.map( "UpdateChangelog@commandbox-semantic-release" )
            .toDSL( settings.plugins.UpdateChangelog );
        binder.map( "CommitArtifacts@commandbox-semantic-release" )
            .toDSL( settings.plugins.CommitArtifacts );
        binder.map( "PublishRelease@commandbox-semantic-release" )
            .toDSL( settings.plugins.PublishRelease );
        binder.map( "PublicizeRelease@commandbox-semantic-release" )
            .toDSL( settings.plugins.PublicizeRelease );
    }

}
