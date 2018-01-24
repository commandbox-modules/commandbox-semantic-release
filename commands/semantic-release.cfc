component {

    property name="VerifyConditions"  inject="VerifyConditions@commandbox-semantic-release";
    property name="GetLastRelease"    inject="GetLastRelease@commandbox-semantic-release";
    property name="AnalyzeCommits"    inject="AnalyzeCommits@commandbox-semantic-release";
    property name="VerifyRelease"     inject="VerifyRelease@commandbox-semantic-release";
    property name="PublishRelease"    inject="PublishRelease@commandbox-semantic-release";
    property name="GenerateNotes"     inject="GenerateNotes@commandbox-semantic-release";
    property name="PublicizeRelease"  inject="PublicizeRelease@commandbox-semantic-release";

    property name="commitParser"      inject="ConventionalChangelogParser@commandbox-semantic-release";
    property name="semanticVersion"   inject="provider:semanticVersion@semver";
    property name="packageService"    inject="packageService";
    property name="systemSettings"    inject="SystemSettings";
    property name="fileSystemUtil"    inject="FileSystem";

    property name="changelogFileName" inject="commandbox:moduleSettings:commandbox-semantic-release:changelogFileName";
    property name="versionPrefix"     inject="commandbox:moduleSettings:commandbox-semantic-release:versionPrefix";

    variables.SEMANTIC_RELEASE_COMMIT_MESSAGE = "__SEMANTIC RELEASE VERSION UPDATE__";

    function run( dryRun = false ) {
        if ( dryRun ) {
            print.indentedYellowLine( "Starting Dry Run..." )
                .line()
                .toConsole();
        }

        if ( ! dryRun && systemSettings.getSystemSetting( "TRAVIS_COMMIT_MESSAGE", "" ) == SEMANTIC_RELEASE_COMMIT_MESSAGE ) {
            print.yellowLine( "Build kicked off from previous release — aborting release." );
            return;
        }

        if ( ! dryRun && ! VerifyConditions.run() ) {
            print.yellowLine( "Verify conditions check failed — aborting release." );
            return;
        }

        print.indentedGreen( "✓" )
            .indentedWhiteLine( "Conditions verified" )
            .toConsole();

        var lastVersion = GetLastRelease.run( getPackageSlug() );
        print.indentedGreen( "✓" )
            .indentedWhite( "Retrieved last version: " )
            .whiteOnCyanLine( " #lastVersion# " )
            .toConsole();

        var commits = getCommits( since = lastVersion );
        var type = AnalyzeCommits.run( commits, dryRun );
        print.indentedGreen( "✓" )
            .indentedWhite( "Next release type: " )
            .line( " #type# ", getTypeColor( type ) );

        var nextVersion = applyVersionChange( lastVersion, type );
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

        if ( ! dryRun ) {
            PublishRelease.run( nextVersion );
        }

        print.indentedGreen( "✓" )
            .indentedWhiteLine( "Release published" )
            .toConsole();

        var notes = GenerateNotes.run( lastVersion, nextVersion, commits, type, getPackageRepositoryURL() );

        if ( ! dryRun ) {
            var changelogNotes = "## #dateFormat( now(), "dd mmm yyyy" )#" & chr(10) & chr(10) & notes;
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

            jGit.add()
                .addFilePattern( "box.json" )
                .addFilePattern( changelogFileName )
                .call();

            var commit = jGit.commit()
                .setMessage( SEMANTIC_RELEASE_COMMIT_MESSAGE )
                .setAuthor( "Travis CI", "builds@travis-ci.com" )
                .call();

            jGit.tag()
                .setMessage( "#versionPrefix##nextVersion#" )
                .setName( "#versionPrefix##nextVersion#" )
                .call();

            var credentials = createObject( "java", "org.eclipse.jgit.transport.UsernamePasswordCredentialsProvider" )
                .init( systemSettings.getSystemSetting( "GH_TOKEN" ), "" );

            jGit.push()
                .setCredentialsProvider( credentials )
                .setPushTags()
                .call();
        }

        print.indentedGreen( "✓" )
            .indentedWhiteLine( "Source control updated" )
            .toConsole();

        if ( ! dryRun ) {
            PublicizeRelease.run( notes, nextVersion, getPackageRepositoryURL() );
        }

        print.indentedGreen( "✓" )
            .indentedWhiteLine( "Release publicized" )
            .toConsole();
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

    // needs to ignore semantic-release commit message commits
    private array function getCommits( since ) {
        var builder = createObject( "java", "org.eclipse.jgit.storage.file.FileRepositoryBuilder" ).init();
        var gitDir = createObject( "java", "java.io.File" ).init( fileSystemUtil.resolvePath( "" ) & ".git" );

        var repository = builder
            .setGitDir( gitDir )
            .setMustExist( true )
            .readEnvironment() // scan environment GIT_* variables
            .findGitDir() // scan up the file system tree
            .build();

        var tagRef = repository.exactRef( "refs/tags/#versionPrefix##since#" );
        var walk = createObject( "java", "org.eclipse.jgit.revwalk.RevWalk" ).init( repository );
        var head = repository.exactRef( "HEAD" );
        walk.markStart( walk.parseCommit( head.getObjectId() ) );
        var commitsArray = [];
        var commitsIterator = walk.iterator();
        if ( isNull( tagRef ) ) {
            while( commitsIterator.hasNext() ) {
                var commit = commitsIterator.next();
                var parsedCommit = commitParser.parse( commit );
                if ( ! parsedCommit.body.contains( SEMANTIC_RELEASE_COMMIT_MESSAGE ) ) {
                    arrayAppend( commitsArray, parsedCommit );
                }
            }
        }
        else {
            var targetId = repository.peel( tagRef ).getPeeledObjectId();
            if ( isNull( targetId ) ) {
                targetId = tagRef.getObjectId();
            }
            while( commitsIterator.hasNext() ) {
                var commit = commitsIterator.next();
                var parsedCommit = commitParser.parse( commit );
                if ( ! parsedCommit.body.contains( SEMANTIC_RELEASE_COMMIT_MESSAGE ) ) {
                    arrayAppend( commitsArray, parsedCommit );
                }
                if ( commit.getId().equals( targetId ) ) {
                    break;
                }
            }
        }
        return commitsArray;
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

    private string function applyVersionChange( required string lastVersion, required string type ) {
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
