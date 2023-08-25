component implements="interfaces.ArtifactsCommitter" {

    /**
     * Gives a chance to commit any changes or artifacts produced by the build.
     *
     * @nextVersion The next version to be published.
     * @dryRun  Flag to indicate a dry run of the release.
     * @verbose Flag to indicate printing out extra information.
     * @targetBranch     The branch that builds are triggered against.
     */
    public void function run(
        required string nextVersion,
        boolean dryRun = false,
        boolean verbose = false, 
        string targetBranch = variables.targetBranch
    ) {
        return;
    }

}
