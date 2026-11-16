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
    <div className={style.addSensor}>
      {showForm ? (
        <button
          className="press-button -ghost"
          onClick={() => {
            setShowForm(false)
            formRef.current?.reset()
          }}
        >
          Hide
        </button>
      ) : (
        <button
          className="press-button -accent"
          onClick={() => setShowForm(true)}
        >
          Add sensor
        </button>
      )}
      {showForm && (
        <form ref={formRef} onSubmit={handleSubmit} className={`paper-card ${style.form}`}>
          <label className="form-field -boxed">
            <span className="label">Name</span>
            <input className="input" name="name" />
          </label>
          <label className="form-field -boxed">
            <span className="label">Serial number</span>
            <input className="input" name="serialno" />
          </label>
          <label className="form-field -boxed">
            <span className="label">Description</span>
            <input className="input" name="description" />
          </label>
          <div className={style.formActions}>
            <button
              type="submit"
              className="press-button -accent"
              disabled={mutation.isPending}
            >
              {mutation.isPending ? 'Adding…' : 'Add sensor'}
            </button>
          </div>
          {mutation.error && <p className={style.errorText}>{mutation.error.message}</p>}
        </form>
      )}
    </div>
  )
}
