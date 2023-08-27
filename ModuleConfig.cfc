component {

    this.name = "commandbox-semantic-release";
    this.autoMapModels = false;
    this.dependencies = [ "hyper" ];

    function configure() {
        settings = {
            "versionPrefix" = "v",
            "changelogFileName" = "CHANGELOG.md",
            "targetBranch" = "master",
            "buildCommitMessage" = "__SEMANTIC RELEASE VERSION UPDATE__",
            "plugins-VerifyConditions" = "GitHubActionsConditionsVerifier@commandbox-semantic-release",
                "plugins-VerifyConditions-buildTimeout" = 600, // seconds
                "plugins-VerifyConditions-pollingInterval" = 5, // seconds
            "plugins-FetchLastRelease" = "ForgeBoxReleaseFetcher@commandbox-semantic-release",
            "plugins-RetrieveCommits"  = "JGitCommitsRetriever@commandbox-semantic-release",
            "plugins-ParseCommit"      = "ConventionalChangelogParser@commandbox-semantic-release",
            "plugins-FilterCommits"    = "DefaultCommitFilterer@commandbox-semantic-release",
            "plugins-AnalyzeCommits"   = "DefaultCommitAnalyzer@commandbox-semantic-release",
            "plugins-VerifyRelease"    = "NullReleaseVerifier@commandbox-semantic-release",
            "plugins-GenerateNotes"    = "GitHubMarkdownNotesGenerator@commandbox-semantic-release",
            "plugins-UpdateChangelog"  = "FileAppendChangelogUpdater@commandbox-semantic-release",
            "plugins-CommitArtifacts"  = "GitHubArtifactsCommitter@commandbox-semantic-release",
                "plugins-CommitArtifacts-authorName" = "CommandBox Semantic Release",
                "plugins-CommitArtifacts-authorEmail" = "csr@example.com",
            "plugins-PublishRelease"   = "ForgeBoxReleasePublisher@commandbox-semantic-release",
            "plugins-PublicizeRelease" = "GitHubReleasePublicizer@commandbox-semantic-release"
        };

        binder.map( "ConventionalChangelogParser@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.ConventionalChangelogParser" );
        binder.map( "DefaultCommitAnalyzer@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.DefaultCommitAnalyzer" );
        binder.map( "DefaultCommitFilterer@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.DefaultCommitFilterer" );
        binder.map( "EmojiLogCommitAnalyzer@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.EmojiLogCommitAnalyzer" );
        binder.map( "EmojiLogCommitParser@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.EmojiLogCommitParser" );
        binder.map( "FileAppendChangelogUpdater@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.FileAppendChangelogUpdater" );
        binder.map( "ForgeBoxReleaseFetcher@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.ForgeBoxReleaseFetcher" );        
        binder.map( "ForgeBoxReleasePublisher@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.ForgeBoxReleasePublisher" );
        binder.map( "GitHubActionsConditionsVerifier@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.GitHubActionsConditionsVerifier" );
        binder.map( "GitHubArtifactsCommitter@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.GitHubArtifactsCommitter" );
        binder.map( "GitHubMarkdownNotesGenerator@commandbox-semantic-release" ).
            to( "#moduleMapping#.models.plugins.GitHubMarkdownNotesGenerator" );
        binder.map( "GitHubReleasePublicizer@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.GitHubReleasePublicizer" );
        binder.map( "GitLabArtifactsCommitter@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.GitLabArtifactsCommitter" );
        binder.map( "GitLabConditionsVerifier@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.GitLabConditionsVerifier" );
        binder.map( "GitLabReleaseFetcher@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.GitLabReleaseFetcher" );
        binder.map( "GitLabReleasePublicizer@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.GitLabReleasePublicizer" );
        binder.map( "JGitCommitsRetriever@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.JGitCommitsRetriever" );
        binder.map( "NullArtifactsCommitter@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.NullArtifactsCommitter" );
        binder.map( "NullConditionsVerifier@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.NullConditionsVerifier" );
        binder.map( "NullNotesGenerator@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.NullNotesGenerator" );
        binder.map( "NullReleasePublisher@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.NullReleasePublisher" );
        binder.map( "NullReleaseVerifier@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.NullReleaseVerifier" );
        binder.map( "TravisConditionsVerifier@commandbox-semantic-release" )
            .to( "#moduleMapping#.models.plugins.TravisConditionsVerifier" );        
    }

    function onLoad() {
        binder.map( "VerifyConditions@commandbox-semantic-release" )
            .toDSL( settings[ "plugins-VerifyConditions" ] );
        binder.map( "FetchLastRelease@commandbox-semantic-release" )
            .toDSL( settings[ "plugins-FetchLastRelease" ] );
        binder.map( "RetrieveCommits@commandbox-semantic-release" )
            .toDSL( settings[ "plugins-RetrieveCommits" ] );
        binder.map( "ParseCommit@commandbox-semantic-release" )
            .toDSL( settings[ "plugins-ParseCommit" ] );
        binder.map( "FilterCommits@commandbox-semantic-release" )
            .toDSL( settings[ "plugins-FilterCommits" ] );
        binder.map( "AnalyzeCommits@commandbox-semantic-release" )
            .toDSL( settings[ "plugins-AnalyzeCommits" ] );
        binder.map( "VerifyRelease@commandbox-semantic-release" )
            .toDSL( settings[ "plugins-VerifyRelease" ] );
        binder.map( "GenerateNotes@commandbox-semantic-release" )
            .toDSL( settings[ "plugins-GenerateNotes" ] );
        binder.map( "UpdateChangelog@commandbox-semantic-release" )
            .toDSL( settings[ "plugins-UpdateChangelog" ] );
        binder.map( "CommitArtifacts@commandbox-semantic-release" )
            .toDSL( settings[ "plugins-CommitArtifacts" ] );
        binder.map( "PublishRelease@commandbox-semantic-release" )
            .toDSL( settings[ "plugins-PublishRelease" ] );
        binder.map( "PublicizeRelease@commandbox-semantic-release" )
            .toDSL( settings[ "plugins-PublicizeRelease" ] );
    }

}
