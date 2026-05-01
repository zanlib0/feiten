import { useQuery } from '@tanstack/react-query'

async function fetchHealth(): Promise<string> {
  const res = await fetch('/api/health')
  if (!res.ok) throw new Error(`Health check failed: ${res.status}`)
  return res.text()
}

function App() {
  const { data, error, isLoading } = useQuery({
    queryKey: ['health'],
    queryFn: fetchHealth,
  })

  return (
    <main>
      <h1>Feiten</h1>
      <p>
        Backend:{' '}
        {isLoading
          ? 'checking…'
          : error
            ? `unreachable (${error.message})`
            : `${data}`}
      </p>
    </main>
  )
}

export default App
