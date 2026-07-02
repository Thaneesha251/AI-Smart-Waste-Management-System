import { useEffect, useState } from 'react';
import { CheckCircle2, XCircle } from 'lucide-react';
import { getVerifications, updateVerification } from '../services/verificationService';
import '../styles/Verification.css';

const Verification = () => {
  const [items, setItems] = useState([]);
  const [selectedId, setSelectedId] = useState(null);
  const [comment, setComment] = useState('');
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    const load = async () => {
      const data = await getVerifications();
      setItems(data);
      if (data[0]) setSelectedId(data[0].id);
    };
    load();
  }, []);

  const selectedItem = items.find((item) => item.id === selectedId) || null;

  const handleDecision = async (status) => {
    if (!selectedItem || saving || selectedItem.status === status) return;
    setSaving(true);
    await updateVerification(selectedItem.id, status, comment);
    setItems((prev) => prev.map((item) => item.id === selectedItem.id ? { ...item, status } : item));
    setSaving(false);
  };

  return (
    <div className="verification-container">
      <div className="ver-list-area">
        <table className="ver-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Complaint</th>
              <th>Worker</th>
              <th>Type</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {items.map((item) => (
              <tr key={item.id} className={selectedId === item.id ? 'selected' : ''} onClick={() => setSelectedId(item.id)}>
                <td>{item.id}</td>
                <td>{item.complaint}</td>
                <td>{item.worker}</td>
                <td>{item.type}</td>
                <td><span className={`status-badge ${item.status === 'Pending' ? 'status-pending' : item.status === 'Approved' ? 'status-resolved' : 'priority-high'}`}>{item.status}</span></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <div className="ver-detail-area">
        {selectedItem ? (
          <>
            <h3>Verification Details: {selectedItem.id}</h3>
            <div className="image-comparison">
              <div className="image-box">
                <div className="image-box-title">Before Image</div>
                <img
                  src={selectedItem.beforeImg}
                  alt="Before"
                  className="ver-img"
                  onError={(e) => {
                    e.target.onerror = null;
                    e.target.src = 'https://placehold.co/600x400/1e293b/94a3b8?text=Before+Image';
                  }}
                />
              </div>
              <div className="image-box">
                <div className="image-box-title">After Image</div>
                <img
                  src={selectedItem.afterImg}
                  alt="After"
                  className="ver-img"
                  onError={(e) => {
                    e.target.onerror = null;
                    e.target.src = 'https://placehold.co/600x400/1e293b/94a3b8?text=After+Image';
                  }}
                />
              </div>
            </div>
            <div className="similarity-score">
              <div>{selectedItem.similarity}</div>
              <span>Similarity Score</span>
            </div>
            <textarea className="ver-comment" value={comment} onChange={(e) => setComment(e.target.value)} placeholder="Add comment" />
            <div className="ver-actions">
              <button className="btn-approve" disabled={saving || selectedItem.status === 'Approved'} onClick={() => handleDecision('Approved')}>
                <CheckCircle2 size={16} /> {saving ? 'Saving...' : 'Approve'}
              </button>
              <button className="btn-reject" disabled={saving || selectedItem.status === 'Rejected'} onClick={() => handleDecision('Rejected')}>
                <XCircle size={16} /> {saving ? 'Saving...' : 'Reject'}
              </button>
            </div>
          </>
        ) : (
          <div className="empty-state">Select a verification task from the list to review details.</div>
        )}
      </div>
    </div>
  );
};

export default Verification;
