import React from 'react';

const DashboardCard = ({ icon: Icon, label, value, sublabel, accentColor, bgColor }) => {
  return (
    <div className="dashboard-card">
      <div className="dashboard-card-icon" style={{ background: bgColor, color: accentColor }}>
        <Icon size={20} />
      </div>
      <div className="dashboard-card-content">
        <div className="card-label">{label}</div>
        <div className="card-value">{value}</div>
        <div className="card-sublabel">{sublabel}</div>
      </div>
      <div className="card-accent" style={{ background: accentColor }} />
    </div>
  );
};

export default DashboardCard;
