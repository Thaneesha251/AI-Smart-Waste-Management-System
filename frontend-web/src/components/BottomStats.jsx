import { Clock, Leaf, Smile, Zap } from 'lucide-react';

const BottomStats = () => {
  const items = [
    { icon: Leaf, title: 'Clean City Mission', value: '98% coverage', accent: 'green' },
    { icon: Zap, title: 'Efficiency', value: '87% this week ↑', accent: 'green' },
    { icon: Clock, title: 'Response Time', value: 'Avg. 42 mins', accent: 'green' },
    { icon: Smile, title: 'Satisfaction Rate', value: '92% citizens happy', accent: 'green' }
  ];

  return (
    <div className="bottom-stats-grid">
      {items.map(({ icon: Icon, title, value }) => (
        <div key={title} className="panel-card bottom-stat-card">
          <div className="bottom-stat-icon">
            <Icon size={20} />
          </div>
          <div>
            <div className="bottom-stat-title">{title}</div>
            <div className="bottom-stat-value">{value}</div>
          </div>
        </div>
      ))}
    </div>
  );
};

export default BottomStats;
