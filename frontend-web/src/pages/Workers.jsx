import { useEffect, useState } from 'react';
import { CheckCircle2, Clock3, MapPin, Phone, X, Mail, Lock } from 'lucide-react';
import { getWorkers, addWorker } from '../services/workersService';

const Workers = () => {
  const [workers, setWorkers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showAddModal, setShowAddModal] = useState(false);
  const [newWorker, setNewWorker] = useState({ name: '', zone: '', phone: '', email: '', password: '' });
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    const load = async () => {
      setLoading(true);
      const data = await getWorkers();
      setWorkers(data);
      setLoading(false);
    };
    load();
  }, []);

  const getStatusClass = (status) => {
    if (status === 'On Duty' || status === 'online') return 'status-resolved';
    if (status === 'On Leave') return 'status-pending';
    return 'status-inprogress';
  };

  const isFormValid = () => {
    return (
      newWorker.name.trim() &&
      newWorker.zone.trim() &&
      newWorker.phone.trim() &&
      newWorker.email.trim() &&
      newWorker.password.trim().length >= 6
    );
  };

  const handleAddWorker = async () => {
    if (!isFormValid()) return;
    setSaving(true);
    try {
      const created = await addWorker(newWorker);
      setWorkers((prev) => [...prev, created]);
      setNewWorker({ name: '', zone: '', phone: '', email: '', password: '' });
      setShowAddModal(false);
    } catch (err) {
      alert(err?.response?.data?.detail || 'Failed to add worker. Email may already be registered.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="content-wrapper">
      <div className="content-header">
        <div>
          <h2 className="header-title">Workers</h2>
          <p className="header-subtitle">Manage field team availability and performance.</p>
        </div>
        <button className="primary-btn" onClick={() => setShowAddModal(true)}>Add Worker</button>
      </div>
      {loading ? <div className="empty-state">Loading workers...</div> : (
        <div className="workers-grid">
          {workers.map((worker) => (
            <div key={worker.id} className="worker-card">
              <div className="worker-header">
                <div className="worker-avatar">{worker.name.slice(0, 2).toUpperCase()}</div>
                <div>
                  <h3>{worker.name}</h3>
                  <div className="muted-text">{worker.zone}</div>
                </div>
              </div>
              <div className="worker-meta"><Mail size={14} /> {worker.email}</div>
              <div className="worker-meta"><Phone size={14} /> {worker.phone}</div>
              <div className="worker-meta"><MapPin size={14} /> {worker.zone}</div>
              <div className="worker-status-row">
                <span className={`status-badge ${getStatusClass(worker.status)}`}>{worker.status}</span>
              </div>
              <div className="worker-stats">
                <div><CheckCircle2 size={16} /> {worker.complaints_completed ?? 0} completed</div>
                <div><Clock3 size={16} /> {worker.average_rating ?? 0} rating</div>
              </div>
            </div>
          ))}
        </div>
      )}

      {showAddModal && (
        <div className="modal-backdrop" onClick={() => setShowAddModal(false)}>
          <div className="modal-card" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>Add New Worker</h3>
              <button className="icon-btn" onClick={() => setShowAddModal(false)}><X size={18} /></button>
            </div>
            <div className="modal-body">
              <label className="field-label">Full Name</label>
<input
  className="assign-input"
  name="worker-name"
  autoComplete="off"
  placeholder="e.g. Vijay Kumar"
  value={newWorker.name}
  onChange={(e) => setNewWorker({ ...newWorker, name: e.target.value })}
/>
<label className="field-label">Email</label>
<input
  type="email"
  className="assign-input"
  name="worker-email"
  autoComplete="new-email"
  placeholder="e.g. vijay@example.com"
  value={newWorker.email}
  onChange={(e) => setNewWorker({ ...newWorker, email: e.target.value })}
/>
<label className="field-label">Zone</label>
<input
  className="assign-input"
  name="worker-zone"
  autoComplete="off"
  placeholder="e.g. Zone G"
  value={newWorker.zone}
  onChange={(e) => setNewWorker({ ...newWorker, zone: e.target.value })}
/>
<label className="field-label">Phone Number</label>
<input
  className="assign-input"
  name="worker-phone"
  autoComplete="off"
  placeholder="e.g. +91 98765 43220"
  value={newWorker.phone}
  onChange={(e) => setNewWorker({ ...newWorker, phone: e.target.value })}
/>
<label className="field-label">Password (for app login)</label>
<input
  type="password"
  className="assign-input"
  name="worker-new-password"
  autoComplete="new-password"
  placeholder="Minimum 6 characters"
  value={newWorker.password}
  onChange={(e) => setNewWorker({ ...newWorker, password: e.target.value })}
/>
            </div>
            <div className="modal-footer">
              <button
                className="assign-confirm-btn"
                disabled={!isFormValid() || saving}
                onClick={handleAddWorker}
              >
                {saving ? 'Adding...' : 'Add Worker'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Workers;
