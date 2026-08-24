declare global {
	namespace App {
		interface Locals {
			adminSession: {
				userId: string;
				role: string;
			} | null;
		}
	}
}

export {};
