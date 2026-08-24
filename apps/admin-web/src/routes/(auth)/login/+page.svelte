<script lang="ts">
	let email = $state('');
	let password = $state('');
	let submitting = $state(false);

	async function handleSubmit(event: SubmitEvent) {
		event.preventDefault();
		submitting = true;
		await new Promise((resolve) => setTimeout(resolve, 400));
		submitting = false;
	}
</script>

<main class="flex min-h-screen items-center justify-center bg-slate-100 px-6">
	<div class="w-full max-w-md rounded-2xl bg-white p-10 shadow-lg">
		<h1 class="text-3xl font-bold text-primary-700">BangunKu Admin</h1>
		<p class="mt-2 text-base text-slate-600">
			Masuk untuk mengelola platform BangunKu.
		</p>

		<form class="mt-8 space-y-5" onsubmit={handleSubmit}>
			<label class="block">
				<span class="text-sm font-medium text-slate-700">Email</span>
				<input
					type="email"
					bind:value={email}
					required
					autocomplete="email"
					class="mt-1 h-12 w-full rounded-lg border border-slate-300 px-4 text-base focus:border-primary-500 focus:outline-none focus:ring-2 focus:ring-primary-100"
				/>
			</label>

			<label class="block">
				<span class="text-sm font-medium text-slate-700">Kata Sandi</span>
				<input
					type="password"
					bind:value={password}
					required
					autocomplete="current-password"
					class="mt-1 h-12 w-full rounded-lg border border-slate-300 px-4 text-base focus:border-primary-500 focus:outline-none focus:ring-2 focus:ring-primary-100"
				/>
			</label>

			<button
				type="submit"
				disabled={submitting}
				class="h-12 w-full rounded-lg bg-primary-600 text-base font-semibold text-white transition hover:bg-primary-700 disabled:opacity-60"
			>
				{submitting ? 'Memproses…' : 'Masuk'}
			</button>
		</form>

		<p class="mt-6 text-sm text-slate-500">
			Akun admin dibuat oleh pengelola platform. Autentikasi penuh tersambung pada Fase 1c.
		</p>
	</div>
</main>
