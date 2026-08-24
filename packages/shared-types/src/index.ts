export const ORG_TYPES = ['PERSONAL', 'BUSINESS', 'CONTRACTOR', 'DEVELOPER'] as const;
export type OrgType = (typeof ORG_TYPES)[number];

export const ORG_STATUSES = ['ACTIVE', 'SUSPENDED', 'ARCHIVED'] as const;
export type OrgStatus = (typeof ORG_STATUSES)[number];

export const MEMBER_ROLES = ['OWNER', 'ADMIN', 'MEMBER', 'VIEWER'] as const;
export type MemberRole = (typeof MEMBER_ROLES)[number];

export const MEMBER_STATUSES = ['ACTIVE', 'INVITED', 'REMOVED'] as const;
export type MemberStatus = (typeof MEMBER_STATUSES)[number];

export const PROFILE_STATUSES = ['ACTIVE', 'SUSPENDED'] as const;
export type ProfileStatus = (typeof PROFILE_STATUSES)[number];

export const PROJECT_TYPES = ['NEW_BUILD', 'RENOVATION', 'OTHER'] as const;
export type ProjectType = (typeof PROJECT_TYPES)[number];

export const PROJECT_STATUSES = ['PLANNING', 'ACTIVE', 'COMPLETED', 'ARCHIVED'] as const;
export type ProjectStatus = (typeof PROJECT_STATUSES)[number];

export const PAYMENT_METHODS = [
  'CASH',
  'BANK_TRANSFER',
  'EWALLET',
  'DEBIT_CARD',
  'CREDIT_CARD',
  'OTHER'
] as const;
export type PaymentMethod = (typeof PAYMENT_METHODS)[number];

export const PROGRESS_CATEGORIES = [
  'PERSIAPAN',
  'PONDASI',
  'STRUKTUR',
  'DINDING',
  'ATAP',
  'LANTAI',
  'PLAFON',
  'MEP',
  'FINISHING'
] as const;
export type ProgressCategory = (typeof PROGRESS_CATEGORIES)[number];

export const WORKER_PAYMENT_TYPES = ['DAILY', 'WEEKLY', 'MONTHLY', 'PROJECT'] as const;
export type WorkerPaymentType = (typeof WORKER_PAYMENT_TYPES)[number];

export const DOCUMENT_TYPES = ['RECEIPT', 'INVOICE', 'CONTRACT', 'PHOTO', 'OTHER'] as const;
export type DocumentType = (typeof DOCUMENT_TYPES)[number];

export const SUBSCRIPTION_STATUSES = [
  'TRIALING',
  'ACTIVE',
  'PAST_DUE',
  'CANCELLED',
  'EXPIRED'
] as const;
export type SubscriptionStatus = (typeof SUBSCRIPTION_STATUSES)[number];

export const PAYMENT_STATUSES = ['PENDING', 'PAID', 'FAILED', 'REFUNDED'] as const;
export type PaymentStatus = (typeof PAYMENT_STATUSES)[number];

export const NOTIFICATION_TARGET_TYPES = [
  'ALL',
  'FREE',
  'PRO',
  'BUSINESS',
  'SPECIFIC_ORGANIZATION',
  'SPECIFIC_USER'
] as const;
export type NotificationTargetType = (typeof NOTIFICATION_TARGET_TYPES)[number];

export const PLAN_CODES = ['FREE', 'PRO', 'BUSINESS'] as const;
export type PlanCode = (typeof PLAN_CODES)[number];

export const ENTITLEMENT_KEYS = [
  'MAX_PROJECTS',
  'MAX_STORAGE_MB',
  'TEAM_MEMBERS',
  'MULTI_PROJECT',
  'PDF_EXPORT',
  'EXCEL_EXPORT',
  'RECEIPT_UPLOAD',
  'ADVANCED_ANALYTICS',
  'AI_INSIGHTS'
] as const;
export type EntitlementKey = (typeof ENTITLEMENT_KEYS)[number];

export const SYNC_STATUSES = [
  'PENDING_CREATE',
  'PENDING_UPDATE',
  'PENDING_DELETE',
  'SYNCED',
  'FAILED'
] as const;
export type SyncStatus = (typeof SYNC_STATUSES)[number];

export const BUDGET_ITEM_STATUSES = ['SAFE', 'WARNING', 'OVER_BUDGET'] as const;
export type BudgetItemStatus = (typeof BUDGET_ITEM_STATUSES)[number];

export const WARNING_THRESHOLD = 0.8;
export const OVER_BUDGET_THRESHOLD = 1;

export interface BaseEntity {
  id: string;
  createdAt: string;
  updatedAt: string;
}

export interface SoftDeletable {
  deletedAt: string | null;
}

export interface Profile extends BaseEntity {
  fullName: string;
  phone: string | null;
  avatarUrl: string | null;
  status: ProfileStatus;
}

export interface Organization extends BaseEntity {
  name: string;
  slug: string;
  type: OrgType;
  ownerId: string;
  status: OrgStatus;
}

export interface OrganizationMember extends BaseEntity {
  organizationId: string;
  userId: string;
  role: MemberRole;
  status: MemberStatus;
}

export interface Project extends BaseEntity, SoftDeletable {
  organizationId: string;
  name: string;
  type: ProjectType;
  address: string | null;
  landArea: number | null;
  buildingArea: number | null;
  numberOfFloors: number;
  budget: number;
  startDate: string | null;
  targetCompletionDate: string | null;
  status: ProjectStatus;
  progressPercentage: number;
}

export interface BudgetCategory extends BaseEntity, SoftDeletable {
  projectId: string;
  name: string;
  sortOrder: number;
}

export interface BudgetItem extends BaseEntity, SoftDeletable {
  projectId: string;
  categoryId: string;
  name: string;
  description: string | null;
  volume: number;
  unit: string | null;
  unitPrice: number;
  estimatedTotal: number;
  notes: string | null;
}

export interface Expense extends BaseEntity, SoftDeletable {
  projectId: string;
  budgetItemId: string | null;
  categoryId: string | null;
  date: string;
  description: string | null;
  amount: number;
  vendor: string | null;
  paymentMethod: PaymentMethod;
  receiptUrl: string | null;
  notes: string | null;
  createdBy: string;
}

export interface ProgressItem extends BaseEntity {
  projectId: string;
  category: ProgressCategory;
  progressPercentage: number;
  startDate: string | null;
  targetDate: string | null;
  actualDate: string | null;
  notes: string | null;
}

export interface Material extends BaseEntity, SoftDeletable {
  projectId: string;
  name: string;
  category: string | null;
  unit: string | null;
  quantity: number;
  unitPrice: number;
  supplier: string | null;
  notes: string | null;
}

export interface Worker extends BaseEntity, SoftDeletable {
  projectId: string;
  name: string;
  role: string | null;
  paymentType: WorkerPaymentType;
  rate: number;
  phone: string | null;
  notes: string | null;
}

export interface WorkerPayment extends BaseEntity, SoftDeletable {
  projectId: string;
  workerId: string;
  date: string;
  amount: number;
  notes: string | null;
}

export interface ProjectDocument extends BaseEntity, SoftDeletable {
  projectId: string;
  type: DocumentType;
  fileName: string;
  filePath: string;
  fileSize: number;
  mimeType: string | null;
  createdBy: string;
}

export interface Plan extends BaseEntity {
  code: PlanCode;
  name: string;
  price: number;
  billingPeriod: 'MONTHLY' | 'YEARLY' | 'LIFETIME';
  description: string | null;
  isActive: boolean;
  sortOrder: number;
}

export interface PlanFeature {
  id: string;
  planId: string;
  featureKey: EntitlementKey;
  value: unknown;
}

export interface Subscription extends BaseEntity {
  organizationId: string;
  planId: string;
  provider: string;
  providerSubscriptionId: string | null;
  status: SubscriptionStatus;
  startDate: string;
  endDate: string | null;
}

export interface AuditLogEntry {
  id: number;
  adminUserId: string | null;
  action: string;
  targetType: string;
  targetId: string | null;
  metadata: Record<string, unknown>;
  ipAddress: string | null;
  userAgent: string | null;
  createdAt: string;
}

export interface BudgetVsActualRow {
  budgetItemId: string | null;
  categoryId: string | null;
  categoryName: string;
  name: string;
  estimatedTotal: number;
  actualTotal: number;
  difference: number;
  utilization: number;
  status: BudgetItemStatus;
}

export function budgetItemStatus(
  actualTotal: number,
  estimatedTotal: number
): BudgetItemStatus {
  if (estimatedTotal <= 0) {
    return actualTotal > 0 ? 'OVER_BUDGET' : 'SAFE';
  }
  const utilization = actualTotal / estimatedTotal;
  if (utilization >= OVER_BUDGET_THRESHOLD) return 'OVER_BUDGET';
  if (utilization >= WARNING_THRESHOLD) return 'WARNING';
  return 'SAFE';
}
