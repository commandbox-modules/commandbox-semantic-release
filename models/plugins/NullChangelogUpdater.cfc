component implements="interfaces.ChangelogUpdater" {

    property name="print"              inject="PrintBuffer";

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

        if ( verbose ) {
            print.line()
                .indented()
                .boldBlackOnYellowLine( "      NULL CHANGELOG UPDATER - NO CHANGELOG WRITTEN      " )
                .line()
                .toConsole();
        }

    }

}
