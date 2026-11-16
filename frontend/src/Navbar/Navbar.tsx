import { Link, useLocation } from 'wouter'

const LINKS = [
  { href: '/', label: 'index' },
  { href: '/sensors', label: 'sensors' },
]

export const Navbar = () => {
  const [location] = useLocation()

  return (
    <div className="container" style={{ paddingTop: "var(--space-5)" }}>
      <header className="press-masthead">
        <Link href="/" className="title">feiten</Link>
        <nav className="nav">
          {LINKS.map(({ href, label }) => (
            <Link key={href} href={href} aria-current={location === href ? 'page' : undefined}>
              {label}
            </Link>
          ))}
        </nav>
      </header>
    </div>
  )
}
