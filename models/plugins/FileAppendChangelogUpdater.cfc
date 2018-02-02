component implements="interfaces.ChangelogUpdater" {

    property name="fileSystemUtil"     inject="FileSystem";
    property name="print"              inject="PrintBuffer";

    property name="changelogFileName"  inject="commandbox:moduleSettings:commandbox-semantic-release:changelogFileName";
    property name="versionPrefix"      inject="commandbox:moduleSettings:commandbox-semantic-release:versionPrefix";

    /**
     * Updates the current changelog with the new notes.
     *
     * @notes   The notes for the new release.
     * @dryRun  Flag to indicate a dry run of the release.
     * @verbose Flag to indicate printing out extra information.
     */
    public void function run(
        required string notes,
        required string nextVersion,
        boolean dryRun = false,
        boolean verbose = false
    ) {
        var changelogNotes = "" &
            "## #versionPrefix##nextVersion#" & chr(10) &
            "#### #dateTimeFormat( now(), "dd mmm yyyy '—' HH:nn:ss 'UTC'", "UTC" )#" & chr(10) &
            chr(10) &
            notes;

        var changelogPath = fileSystemUtil.resolvePath( "" ) & changelogFileName;

        if ( fileExists( changelogPath ) ) {
            var currentChangelog = fileRead( changelogPath );
            changelogNotes = changelogNotes & chr(10) & chr(10) & currentChangelog;
        }

        if ( verbose ) {
            print.line()
                .indented()
                .boldBlackOnYellowLine( "      NEW CHANGELOG      " )
                .line()
                .whiteLine( changelogNotes )
                .line()
                .indented()
                .boldBlackOnYellowLine( "      END CHANGELOG      " )
                .line()
                .toConsole();
        }

        if ( ! dryRun ) {
            fileWrite( changelogPath, changelogNotes );
        }
    }

}
