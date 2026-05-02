import style from './style.module.css'

export const Navbar = () => {
  return (
    <nav className={style.wrapper}>
      <div className={style.navbar}>
        <a href="/">
          <h1>Feiten</h1>
        </a>
        <div className={style.spacer} />
        <a href="/sensors">Sensors</a>
      </div>
    </nav>
  )
}
