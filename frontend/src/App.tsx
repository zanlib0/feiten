import { Route, Switch } from "wouter";
import { IndexPage } from "./pages/IndexPage";
import { Status } from "./Status";
import { Navbar } from "./Navbar/Navbar";

export const App = () => (
  <>
    <Navbar />
    <Switch>
      <Route path="/" component={IndexPage} />
    </Switch>
    <Status />
  </>
)
