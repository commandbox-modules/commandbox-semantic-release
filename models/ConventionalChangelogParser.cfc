component {

    property name="fileSystemUtil" inject="FileSystem";

    function onDIComplete() {
        var builder = createObject( "java", "org.eclipse.jgit.storage.file.FileRepositoryBuilder" ).init();
        var gitDir = createObject( "java", "java.io.File" ).init( fileSystemUtil.resolvePath( "" ) & ".git" );

        var repository = builder
            .setGitDir( gitDir )
            .setMustExist( true )
            .readEnvironment() // scan environment GIT_* variables
            .findGitDir() // scan up the file system tree
            .build();

        variables.objectReader = repository.newObjectReader();
    }

    public struct function parse( commit ) {
        var ccCommit = {};
        var parts = listToArray( commit.getFullMessage(), "#chr(10)#" );
        var topParts = reFindNoCase( "^(\w+)\(([^)]+)\)\:\s(.+)$", parts[ 1 ], 1, true );

        ccCommit[ "type" ] = topParts.pos.len() >= 2 ?
            mid( parts[ 1 ], topParts.pos[ 2 ], topParts.len[ 2 ] ) :
            "other";
        ccCommit[ "scope" ] = topParts.pos.len() >= 3 ?
            mid( parts[ 1 ], topParts.pos[ 3 ], topParts.len[ 3 ] ) :
            "*";
        ccCommit[ "subject" ] = topParts.pos.len() >= 4 ?
            mid( parts[ 1 ], topParts.pos[ 4 ], topParts.len[ 4 ] ) :
            "";
        ccCommit[ "body" ] = topParts.pos.len() == 1 ? parts[ 1 ] : parts[ 2 ] ?: "";
        ccCommit[ "footer" ] = parts[ 3 ] ?: "";
        ccCommit[ "isBreakingChange" ] = find( "BREAKING CHANGE:", ccCommit.footer ) > 0;
        ccCommit[ "hash" ] = commit.getId().getName();
        ccCommit[ "shortHash" ] = objectReader.abbreviate( commit.getId() ).name();

        return ccCommit;
    }

}
