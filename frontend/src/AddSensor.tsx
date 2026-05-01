export const AddSensor = () => {
  const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    const form = new FormData(event.currentTarget)
    fetch("/api/sensors", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        data: {
          name: form.get("name"),
          serialno: form.get("serialno"),
          description: form.get("description"),
        },
      }),
    })
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="name" placeholder="Name" />
      <input name="serialno" placeholder="Serialno" />
      <input name="description" placeholder="description" />
      <button type="submit">Add sensor</button>
    </form>
  )
}
