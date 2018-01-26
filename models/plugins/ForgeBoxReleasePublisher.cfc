component implements="interfaces.ReleasePublisher" {

    property name="wirebox" inject="wirebox";
    property name="print"   inject="PrintBuffer";

    /**
     * Publishes the new release on ForgeBox.
     *
     * @nextVersion The next version number to publish.
     * @dryRun  Flag to indicate a dry run of the release.
     * @verbose Flag to indicate printing out extra information.
     */
    public void function run(
        required string nextVersion,
        boolean dryRun = false,
        boolean verbose = false
    ) {
        if ( dryRun ) {
            return;
        }

        if ( verbose ) {
            print.line().toConsole();
        }

        // set next version
        wirebox.getInstance(
                name = "CommandDSL",
                initArguments = { name = "package version" }
            )
            .params(
                version = nextVersion,
                tagVersion = false
            )
            .run( returnOutput = ! verbose );

        // publish to ForgeBox
        wirebox.getInstance(
                name = "CommandDSL",
                initArguments = { name = "forgebox publish" }
            )
            .run( returnOutput = ! verbose );

        if ( verbose ) {
            print.line().toConsole();
        }
    }

}
