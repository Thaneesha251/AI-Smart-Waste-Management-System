"""add worker fields

Revision ID: 00b67ca32784
Revises: 4b458c78f3a0
Create Date: 2026-07-20 09:17:25.697810

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '00b67ca32784'
down_revision: Union[str, Sequence[str], None] = '4b458c78f3a0'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    # Using batch_alter_table for SQLite compatibility
    with op.batch_alter_table('complaints', schema=None) as batch_op:
        batch_op.add_column(sa.Column('worker_id', sa.Integer(), nullable=True))
        batch_op.add_column(sa.Column('started_at', sa.DateTime(timezone=True), nullable=True))
        batch_op.add_column(sa.Column('completed_at', sa.DateTime(timezone=True), nullable=True))
        batch_op.create_foreign_key('fk_complaints_worker_id_users', 'users', ['worker_id'], ['id'])


def downgrade() -> None:
    """Downgrade schema."""
    with op.batch_alter_table('complaints', schema=None) as batch_op:
        batch_op.drop_constraint('fk_complaints_worker_id_users', type_='foreignkey')
        batch_op.drop_column('completed_at')
        batch_op.drop_column('started_at')
        batch_op.drop_column('worker_id')
