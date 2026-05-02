import { Stack, Group, Title, Button } from "@mantine/core"
import { Link } from "wouter"

import classes from './Navbar.module.css'

export const Navbar = () => {
  return (
    <Stack align="center" w="100%">
      <Group
        className={classes.navbar}
      >
        <Link href="/">
          <Title order={3} c="white">Feiten</Title>
        </Link>
        <Link href="/sensors" asChild>
          <Button component="a" style={{ alignSelf: 'end' }}>Sensors</Button>
        </Link>
      </Group>
    </Stack>
  )
}
