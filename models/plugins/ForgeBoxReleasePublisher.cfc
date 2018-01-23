component implements="interfaces.ReleasePublisher" {

    property name="wirebox"          inject="wirebox";

    public void function run( required string nextVersion ) {

        // set next version
        wirebox.getInstance(
                name = "CommandDSL",
                initArguments = { name = "package version" }
            )
            .params(
                version = nextVersion,
                tagVersion = false
            )
            .run();

        // publish to ForgeBox
        wirebox.getInstance(
                name = "CommandDSL",
                initArguments = { name = "forgebox publish" }
            )
            .run();
    }

}
