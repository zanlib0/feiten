import { Route, Switch } from "wouter"
import { Status } from "./Status"

import { IndexPage } from './routes/index/IndexPage'
import { Navbar } from "./shared/Navbar"

export const App = () => {
  return (
    <>
      <Navbar />
      <Switch>
        <Route path="/" component={IndexPage} />
      </Switch>
      <Status />
    </>
  )
}
