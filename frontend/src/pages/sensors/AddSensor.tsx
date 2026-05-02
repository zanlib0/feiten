import { useRef, useState } from 'react'
import { useCreateSensor } from '../../api/sensors'

import style from './style.module.css'

export const AddSensor = () => {
  const formRef = useRef<HTMLFormElement>(null)
  const [showForm, setShowForm] = useState<boolean>(false);
  const mutation = useCreateSensor()

  const handleSubmit = (event: React.SubmitEvent<HTMLFormElement>) => {
    event.preventDefault()
    const form = new FormData(event.currentTarget)
    const description = form.get('description')
    mutation.mutate(
      {
        name: String(form.get('name') ?? ''),
        serialno: String(form.get('serialno') ?? ''),
        description: description ? String(description) : undefined,
      },
      {
        onSuccess: () => formRef.current?.reset(),
      },
    )
  }

  return (
    <>
      {showForm ? (
        <button
          onClick={() => {
            setShowForm(false)
            formRef.current?.reset()
          }}
          className={style.addSensor}
        >
          Hide
        </button>
      ) : (
        <button onClick={() => setShowForm(true)} className={style.addSensor}>Add sensor</button>
      )}
      {showForm && (
        <form ref={formRef} onSubmit={handleSubmit}>
          <input name="name" placeholder="Name" />
          <input name="serialno" placeholder="Serial Number" />
          <input name="description" placeholder="Description" />
          <button type="submit" disabled={mutation.isPending}>
            {mutation.isPending ? 'Adding…' : 'Add sensor'}
          </button>
          {mutation.error && <p className="error">{mutation.error.message}</p>}
        </form>
      )}
    </>
  )
}
