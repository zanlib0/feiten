import { Route, Switch } from "wouter";
import { IndexPage } from "./pages/IndexPage";
import { Status } from "./Status";

export const App = () => (
  <>
    <Switch>
      <Route path="/" component={IndexPage} />
    </Switch>
    <Status />
  </>
)
