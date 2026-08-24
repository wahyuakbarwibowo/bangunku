<script lang="ts">
	import Sidebar from '$lib/components/Sidebar.svelte';

	let { children } = $props();
</script>

<div class="flex min-h-screen">
	<Sidebar />
	<div class="flex flex-1 flex-col">
		<header class="flex h-16 items-center justify-between border-b border-slate-200 bg-white px-8">
			<p class="text-sm font-medium text-slate-500">Panel Admin BangunKu</p>
			<div class="flex items-center gap-3">
				<span class="text-sm font-semibold text-slate-700">Admin</span>
				<span class="flex h-10 w-10 items-center justify-center rounded-full bg-primary-100 text-base font-bold text-primary-700">
					A
				</span>
			</div>
		</header>
		<main class="flex-1 bg-slate-50 p-8">
			{@render children()}
		</main>
	</div>
</div>
