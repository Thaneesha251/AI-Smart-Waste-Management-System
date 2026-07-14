import { useEffect, useState } from 'react';
import { CheckCircle2, Clock3, MapPin, Phone, X } from 'lucide-react';
import { getWorkers, addWorker } from '../services/workersService';

const Workers = () => {
  const [workers, setWorkers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showAddModal, setShowAddModal] = useState(false);
  const [newWorker, setNewWorker] = useState({ name: '', zone: '', phone: '' });
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
    if (status === 'On Duty') return 'status-resolved';
    if (status === 'On Leave') return 'status-pending';
    return 'status-inprogress';
  };

  const handleAddWorker = async () => {
    if (!newWorker.name.trim() || !newWorker.zone.trim() || !newWorker.phone.trim()) return;
    setSaving(true);
    const created = await addWorker(newWorker);
    setWorkers((prev) => [...prev, created]);
    setNewWorker({ name: '', zone: '', phone: '' });
    setSaving(false);
    setShowAddModal(false);
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
              <div className="worker-meta"><Phone size={14} /> {worker.phone}</div>
              <div className="worker-meta"><MapPin size={14} /> {worker.zone}</div>
              <div className="worker-status-row">
                <span className={`status-badge ${getStatusClass(worker.status)}`}>{worker.status}</span>
              </div>
              <div className="worker-stats">
                <div><CheckCircle2 size={16} /> {worker.completed} completed</div>
                <div><Clock3 size={16} /> {worker.tasks} pending</div>
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
                placeholder="e.g. Vijay Kumar"
                value={newWorker.name}
                onChange={(e) => setNewWorker({ ...newWorker, name: e.target.value })}
              />
              <label className="field-label">Zone</label>
              <input
                className="assign-input"
                placeholder="e.g. Zone G"
                value={newWorker.zone}
                onChange={(e) => setNewWorker({ ...newWorker, zone: e.target.value })}
              />
              <label className="field-label">Phone Number</label>
              <input
                className="assign-input"
                placeholder="e.g. +91 98765 43220"
                value={newWorker.phone}
                onChange={(e) => setNewWorker({ ...newWorker, phone: e.target.value })}
              />
            </div>
            <div className="modal-footer">
              <button
                className="assign-confirm-btn"
                disabled={!newWorker.name.trim() || !newWorker.zone.trim() || !newWorker.phone.trim() || saving}
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
