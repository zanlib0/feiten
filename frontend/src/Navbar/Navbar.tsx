import { Link } from 'wouter'
import style from './style.module.css'

export const Navbar = () => {
  return (
    <header className="press-masthead" style={{ padding: "var(--space-6)" }}>
      <div className="title">
        <Link href="/" className={style.title}>
          <span>Feiten</span>
        </Link>
      </div>
      <nav className="nav">
        <Link href="/sensors">Sensors</Link>
      </nav>
    </header>
  )
}
