import { Route, Switch } from "wouter"
import { Status } from "./Status"

import { IndexPage } from './routes/index/IndexPage'

export const App = () => {
  return (
    <>
      <Switch>
        <Route path="/" component={IndexPage} />
      </Switch>
      <Status />
    </>
  )
}
