component implements="interfaces.ConditionsVerifier" {

    /**
    * Verifies the conditions are right to run the release.
    *
    * @dryRun  Flag to indicate a dry run of the release.
    * @verbose Flag to indicate printing out extra information.
    *
    * @returns True if the release should run.
    */
    public boolean function run( boolean dryRun = false, boolean verbose = false ) {
        return true;
    }

}
