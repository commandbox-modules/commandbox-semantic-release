component {

    property name="semanticVersion"    inject="provider:semanticVersion@semver";
    property name="packageService"     inject="packageService";
    property name="fileSystemUtil"     inject="FileSystem";
    property name="systemSettings"     inject="SystemSettings";

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
    property name="targetBranch"       inject="commandbox:moduleSettings:commandbox-semantic-release:targetBranch";

    function run( dryRun = false, verbose = false, force = false, targetBranch = variables.targetBranch, preReleaseID = systemSettings.getSystemSetting( "BUILD_VERSION_PRERELEASEID", "" ), buildID = systemSettings.getSystemSetting( "BUILD_VERSION_BUILDID", 0 ) ) {
        if( verbose ){
            print.boldWhiteOnBlackLine( "Arguments to Command" ).toConsole();
            print.line( serializeJSON( arguments ) ).toConsole();
        }
        
        if ( dryRun ) {
            print.line()
                .boldBlackOnYellowLine( "                                " )
                .boldBlackOnYellowLine( "        Starting Dry Run        " )
                .boldBlackOnYellowLine( "                                " )
                .line()
                .toConsole();
        }

        if ( force ) {
            print.yellowLine( "Skipping verification checks due to force flag" ).toConsole();
        }
        else if ( ! VerifyConditions.run( dryRun, verbose ) ) {
            print.yellowLine( "Verify conditions check failed — switching to dry run mode." ).toConsole();
            arguments.dryRun = true;
            print.line()
                .boldBlackOnYellowLine( "                                " )
                .boldBlackOnYellowLine( "        Starting Dry Run        " )
                .boldBlackOnYellowLine( "                                " )
                .line()
                .toConsole();
        }
        else {
            print.indentedGreen( "✓" )
            .indentedWhiteLine( "Conditions verified" )
            .toConsole();
        }

        try {
            var lastVersion = FetchLastRelease.run( getPackageSlug() );
        }
        catch( forgebox e ) {
            return error( "Unable to fetch last version. Aborting", e.message );
        }

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

        var nextVersion = getNextVersionNumber( lastVersion, type, arguments.preReleaseID, arguments.buildID );
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

        UpdateChangelog.run( notes, nextVersion, dryRun, verbose );
        print.indentedGreen( "✓" )
            .indentedWhiteLine( "Changelog updated" )
            .toConsole();

        PublishRelease.run( nextVersion, dryRun, verbose );
        print.indentedGreen( "✓" )
            .indentedWhiteLine( "Release published" )
            .toConsole();

        CommitArtifacts.run( nextVersion, dryRun, verbose, targetBranch );
        print.indentedGreen( "✓" )
            .indentedWhiteLine( "Artifacts committed" )
            .toConsole();

        PublicizeRelease.run(
            notes,
            nextVersion,
            getPackageRepositoryURL(),
            dryRun,
            verbose,
            targetBranch
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

    private string function getNextVersionNumber( required string lastVersion, required string type, string preReleaseID = "", string buildID = 0 ) {
        var versionInfo = semanticVersion.parseVersion( lastVersion );
        versionInfo.preReleaseID = arguments.preReleaseID;
        versionInfo.buildID = arguments.buildID;

        if ( lastVersion == "0.0.0" ) {
            versionInfo.major = 1;
            versionInfo.minor = 0;
            versionInfo.revision = 0;
            versionInfo.preReleaseID = "";
            versionInfo.buildID = 0;
            return semanticVersion.getVersionAsString( versionInfo );
        }

        switch ( type ) {
            case "major":
                if ( versionInfo.major == 0 ) {
                    versionInfo.minor += 1;
                } else {
                    versionInfo.major += 1;
                    versionInfo.minor = 0;
                }
                versionInfo.revision = 0;
                break;
            case "minor":
                if ( versionInfo.major == 0 ) {
                    versionInfo.revision += 1;
                } else {
                    versionInfo.minor += 1;
                    versionInfo.revision = 0;
                }
                break;
            case "patch":
                versionInfo.revision += 1;
                break;
        }
        
        print.boldWhiteOnBlackLine( "Version Info" ).toConsole();
        print.table( [ versionInfo ] ).toConsole();
    
        return semanticVersion.getVersionAsString( versionInfo )
    }

}
