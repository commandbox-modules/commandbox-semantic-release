component {

    property name="semanticVersion"    inject="provider:semanticVersion@semver";
    property name="packageService"     inject="packageService";
    property name="fileSystemUtil"     inject="FileSystem";

    // Plugins
    property name="VerifyConditions"   inject="VerifyConditions@commandbox-semantic-release";
    property name="FetchLastRelease"   inject="FetchLastRelease@commandbox-semantic-release";
    property name="RetrieveCommits"    inject="RetrieveCommits@commandbox-semantic-release";
    property name="ParseCommit"        inject="ParseCommit@commandbox-semantic-release";
    property name="FilterCommits"      inject="FilterCommits@commandbox-semantic-release";
    property name="AnalyzeCommits"     inject="AnalyzeCommits@commandbox-semantic-release";
    property name="VerifyRelease"      inject="VerifyRelease@commandbox-semantic-release";
    property name="GenerateNotes"      inject="GenerateNotes@commandbox-semantic-release";
    property name="UpdateChangelog"    inject="UpdateChangelog@commandbox-semantic-release";
    property name="CommitArtifacts"    inject="CommitArtifacts@commandbox-semantic-release";
    property name="PublishRelease"     inject="PublishRelease@commandbox-semantic-release";
    property name="PublicizeRelease"   inject="PublicizeRelease@commandbox-semantic-release";



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

        var lastVersion = FetchLastRelease.run( getPackageSlug() );
        print.indentedGreen( "✓" )
            .indentedWhite( "Retrieved last version: " )
            .whiteOnCyanLine( " #lastVersion# " )
            .toConsole();

        var commits = RetrieveCommits.run( lastVersion, dryRun, verbose );
        print.indentedGreen( "✓" )
            .indentedWhiteLine( "Commits retrieved" )
            .toConsole();

        if ( commits.isEmpty() ) {
            print.yellowLine( "No changes detected — aborting release." );
            return;
        }

        var parsedCommits = commits.map( function( commit ) {
            return ParseCommit.run( commit, dryRun, verbose );
        } );
        print.indentedGreen( "✓" )
            .indentedWhiteLine( "Commits parsed" )
            .toConsole();

        parsedCommits = FilterCommits.run( parsedCommits, dryRun, verbose );
        print.indentedGreen( "✓" )
            .indentedWhiteLine( "Commits filtered" )
            .toConsole();

        var type = AnalyzeCommits.run( parsedCommits, dryRun );
        print.indentedGreen( "✓" )
            .indentedWhite( "Next release type: " )
            .line( " #type# ", getTypeColor( type ) );

        var nextVersion = getNextVersionNumber( lastVersion, type );
        print.indentedGreen( "✓" )
            .indentedWhite( "Next version number: " )
            .whiteOnCyanLine( " #nextVersion# " )
            .toConsole();

        if ( ! VerifyRelease.run( lastVersion, nextVersion, parsedCommits, type ) ) {
            print.yellowLine( "Verify release check failed — aborting release." );
            return;
        }
        print.indentedGreen( "✓" )
            .indentedWhiteLine( "Release verified" )
            .toConsole();

        var notes = GenerateNotes.run(
            lastVersion,
            nextVersion,
            parsedCommits,
            type,
            getPackageRepositoryURL(),
            dryRun,
            verbose
        );
        print.indentedGreen( "✓" )
            .indentedWhiteLine( "Notes generated" )
            .toConsole();

        UpdateChangelog.run( notes, dryRun, verbose );
        print.indentedGreen( "✓" )
            .indentedWhiteLine( "Changelog updated" )
            .toConsole();

        PublishRelease.run( nextVersion, dryRun, verbose );
        print.indentedGreen( "✓" )
            .indentedWhiteLine( "Release published" )
            .toConsole();

        CommitArtifacts.run( nextVersion, dryRun, verbose );
        print.indentedGreen( "✓" )
            .indentedWhiteLine( "Artifacts committed" )
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
