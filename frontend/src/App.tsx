import { Route, Switch } from "wouter";
import { IndexPage } from "./pages/IndexPage";
import { Status } from "./Status";
import { Navbar } from "./Navbar/Navbar";
import { SensorsPage } from "./pages/sensors/SensorsPage";

export const App = () => (
  <>
    <Navbar />
    <Switch>
      <Route path="/" component={IndexPage} />
      <Route path="/sensors" component={SensorsPage} />
    </Switch>
    <Status />
  </>
)
