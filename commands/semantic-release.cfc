component {

    // Plugins
    property name="VerifyConditions"   inject="VerifyConditions@commandbox-semantic-release";
    property name="ReleaseFetcher"     inject="ReleaseFetcher@commandbox-semantic-release";
    property name="CommitsRetriever"   inject="CommitsRetriever@commandbox-semantic-release";
    property name="CommitParser"       inject="CommitParser@commandbox-semantic-release";
    property name="AnalyzeCommits"     inject="AnalyzeCommits@commandbox-semantic-release";
    property name="VerifyRelease"      inject="VerifyRelease@commandbox-semantic-release";
    property name="PublishRelease"     inject="PublishRelease@commandbox-semantic-release";
    property name="GenerateNotes"      inject="GenerateNotes@commandbox-semantic-release";
    property name="PublicizeRelease"   inject="PublicizeRelease@commandbox-semantic-release";

    property name="semanticVersion"    inject="provider:semanticVersion@semver";
    property name="packageService"     inject="packageService";
    property name="systemSettings"     inject="SystemSettings";
    property name="fileSystemUtil"     inject="FileSystem";

    property name="changelogFileName"  inject="commandbox:moduleSettings:commandbox-semantic-release:changelogFileName";
    property name="versionPrefix"      inject="commandbox:moduleSettings:commandbox-semantic-release:versionPrefix";
    property name="targetBranch"       inject="commandbox:moduleSettings:commandbox-semantic-release:targetBranch";
    property name="buildCommitMessage" inject="commandbox:moduleSettings:commandbox-semantic-release:buildCommitMessage";

    function run( dryRun = false, verbose = false ) {
        if ( dryRun ) {
            print.line()
                .boldBlackOnYellowLine( "                                " )
                .boldBlackOnYellowLine( "        Starting Dry Run        " )
                .boldBlackOnYellowLine( "                                " )
                .line()
                .toConsole();
        }

        if ( ! VerifyConditions.run( dryRun, verbose ) ) {
            print.yellowLine( "Verify conditions check failed — aborting release." );
            return;
        }

        print.indentedGreen( "✓" )
                .indentedWhiteLine( "Conditions verified" )
                .toConsole();

        var lastVersion = ReleaseFetcher.run( getPackageSlug() );
        print.indentedGreen( "✓" )
            .indentedWhite( "Retrieved last version: " )
            .whiteOnCyanLine( " #lastVersion# " )
            .toConsole();

        var commits = CommitsRetriever.run( lastVersion, dryRun, verbose );

        // TODO: does this belong here or in a plugin?
        if ( commits.isEmpty() ) {
            print.yellowLine( "No changes detected — aborting release." );
            return;
        }

        var type = AnalyzeCommits.run( commits, dryRun );
        print.indentedGreen( "✓" )
            .indentedWhite( "Next release type: " )
            .line( " #type# ", getTypeColor( type ) );

        var nextVersion = getNextVersionNumber( lastVersion, type );
        print.indentedGreen( "✓" )
            .indentedWhite( "Next version number: " )
            .whiteOnCyanLine( " #nextVersion# " )
            .toConsole();

        if ( ! VerifyRelease.run( lastVersion, nextVersion, commits, type ) ) {
            print.yellowLine( "Verify release check failed — aborting release." );
            return;
        }

        print.indentedGreen( "✓" )
            .indentedWhiteLine( "Release verified" )
            .toConsole();

        PublishRelease.run( nextVersion, dryRun, verbose );

        print.indentedGreen( "✓" )
            .indentedWhiteLine( "Release published" )
            .toConsole();

        var notes = GenerateNotes.run(
            lastVersion,
            nextVersion,
            commits,
            type,
            getPackageRepositoryURL(),
            dryRun,
            verbose
        );

        if ( ! dryRun ) {
            // TODO: what plugin makes sense to house this?
            var changelogNotes = "## #dateTimeFormat( now(), "dd mmm yyyy '—' HH:nn:ss 'UTC'", "UTC" )#" & chr(10) & chr(10) & notes;
            var changelogPath = fileSystemUtil.resolvePath( "" ) & changelogFileName;
            if ( fileExists( changelogPath ) ) {
                var currentChangelog = fileRead( changelogPath );
                changelogNotes = changelogNotes & chr(10) & chr(10) & currentChangelog;
            }
            fileWrite( changelogPath, changelogNotes );
        }

        print.indentedGreen( "✓" )
            .indentedWhiteLine( "Notes generated" )
            .toConsole();



        // TODO: Extract to method or plugin
        if ( ! dryRun ) {
            var builder = createObject( "java", "org.eclipse.jgit.storage.file.FileRepositoryBuilder" ).init();
            var gitDir = createObject( "java", "java.io.File" ).init( fileSystemUtil.resolvePath( "" ) & ".git" );
            var repository = builder
                .setGitDir( gitDir )
                .setMustExist( true )
                .readEnvironment() // scan environment GIT_* variables
                .findGitDir() // scan up the file system tree
                .build();
            var jGit = createObject( "java", "org.eclipse.jgit.api.Git" ).init( repository );

            jGit.checkout()
                .setName( targetBranch )
                .call();

            jGit.add()
                .addFilePattern( "box.json" )
                .addFilePattern( changelogFileName )
                .call();

            var commit = jGit.commit()
                .setMessage( buildCommitMessage )
                // TODO: move this to configuration or plugin somehow
                .setAuthor( "Travis CI", "builds@travis-ci.com" )
                .call();

            jGit.tag()
                .setMessage( "#versionPrefix##nextVersion#" )
                .setName( "#versionPrefix##nextVersion#" )
                .call();

            // TODO: Move this to configuration or plugin somehow
            var credentials = createObject( "java", "org.eclipse.jgit.transport.UsernamePasswordCredentialsProvider" )
                .init( systemSettings.getSystemSetting( "GH_TOKEN" ), "" );

            jGit.push()
                .setDryRun( dryRun )
                .setCredentialsProvider( credentials )
                .call();

            jGit.push()
                .setDryRun( dryRun )
                .setCredentialsProvider( credentials )
                .setPushTags()
                .call();
        }

        print.indentedGreen( "✓" )
            .indentedWhiteLine( "Source control updated" )
            .toConsole();

        PublicizeRelease.run(
            notes,
            nextVersion,
            getPackageRepositoryURL(),
            dryRun,
            verbose
        );

        print.indentedGreen( "✓" )
            .indentedWhiteLine( "Release publicized" )
            .toConsole();

        if ( dryRun ) {
            print.line()
                .boldBlackOnYellowLine( "                                " )
                .boldBlackOnYellowLine( "        Finished Dry Run        " )
                .boldBlackOnYellowLine( "                                " )
                .line()
                .toConsole();
        }
    }

    private string function getPackageSlug() {
        var path = fileSystemUtil.resolvePath( "" );
        if ( ! packageService.isPackage( path ) ) {
            throw(
                "Sorry but [#path#] isn't a package.",
                "endpointException",
                "Please double check you're in the correct directory or use ""package init"" to turn your directory into a package."
            );
        }
        return packageService.readPackageDescriptor( path ).slug;
    }

    private string function getPackageRepositoryURL() {
        var path = fileSystemUtil.resolvePath( "" );
        if ( ! packageService.isPackage( path ) ) {
            throw(
                "Sorry but [#path#] isn't a package.",
                "endpointException",
                "Please double check you're in the correct directory or use ""package init"" to turn your directory into a package."
            );
        }
        return packageService.readPackageDescriptor( path ).repository.url;
    }

    private string function getTypeColor( required string type ) {
        switch ( type ) {
            case "major":
                return "white onRed";
            case "minor":
                return "black onGreen";
            case "patch":
            default:
                return "black onYellow";
        }
    }

    private string function getNextVersionNumber( required string lastVersion, required string type ) {
        var versionInfo = semanticVersion.parseVersion( lastVersion );

        if ( lastVersion == "0.0.0" ) {
            versionInfo.major = 1;
            versionInfo.minor = 0;
            versionInfo.revision = 0;
            return semanticVersion.getVersionAsString( versionInfo );
        }

        switch ( type ) {
            case "major":
                versionInfo.major += 1;
                versionInfo.minor = 0;
                versionInfo.revision = 0;
                break;
            case "minor":
                versionInfo.minor += 1;
                versionInfo.revision = 0;
                break;
            case "patch":
                versionInfo.revision += 1;
                break;
        }
        return semanticVersion.getVersionAsString( versionInfo )
    }

}
