import { main } from "../output/Test.Browser/index.js";

mocha.setup("bdd");
main();
mocha.run();
