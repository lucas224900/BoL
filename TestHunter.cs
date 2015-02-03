

using System.Linq;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using ReBot.API;
using System;
using System.IO;
using System.Net;

// Based on the work of Sleeper.

namespace ReBot
{
	[Rotation("Survivalist", "Jizar","Survival Hunter CC v1.0.2", WoWClass.Hunter, Specialization.HunterBeastMastery, 40)]
	public class Survivalist : CombatRotation
	{
	    public enum MDtyp
		{
			NoMisdirection ,
			MisdirectionOnPetGlyphed ,
			MisdirectionOnPet ,
			MisdirectionOnFocus , 
		}
	
		public enum PetTyp
		{
				PetSlot1 ,
				PetSlot2 ,
				PetSlot3 ,
				PetSlot4 ,
				PetSlot5 ,
		}
		
		public enum UsePetOrLWtyp
		{
				UsePet ,
				NoPet ,
				LoneWolfCrit,
				LoneWolfMastery,
				LoneWolfHaste ,
				LoneWolfStats ,
				LoneWolfStamina ,
				LoneWolfMultistrike ,
				LoneWolfVersatility ,
				LoneWolfSpellpower ,
		}
	
		/// Basic options
		[JsonProperty("Use your Pet?"), JsonConverter(typeof(StringEnumConverter))]							
		public  UsePetOrLWtyp UsePetOrLWopt = UsePetOrLWtyp.UsePet;
		[JsonProperty("If Use Pet: which Pet Slot"), JsonConverter(typeof(StringEnumConverter))]							
		public PetTyp PetOpt = PetTyp.PetSlot1;
		
		/// Advanced options
		[JsonProperty("Use Tranquilizing Shot")]
        public bool UseTranqShot { get; set; }
		
		[JsonProperty("Use Camouflage")]
        public bool Camo { get; set; }
		
		[JsonProperty("Use Intimidation")]
        public bool Intimidation { get; set; }
		
		[JsonProperty("Use Deterrence")]
        public bool Deterrence { get; set; }
		
		[JsonProperty("Use Aspect of Cheetah not in combat")]
        public bool Cheetah { get; set; }
		
		[JsonProperty("AOE")]
        public bool AOE { get; set; }

		/// MD options
		[JsonProperty("Misdirection"), JsonConverter(typeof(StringEnumConverter))]							
		public MDtyp MDopt = MDtyp.NoMisdirection;
		
		public Survivalist()
		{
            Version CurrentVersion = new Version("1.0.2");
			using (WebClient client = new WebClient())
			{
				Version latest = new Version(client.DownloadString("https://raw.githubusercontent.com/Jizar07/Rebot-Combat-Rotations/master/Hunter/Survivalist.cs"));
				if (CurrentVersion > latest)
                {
                    System.IO.File.WriteAllText("C:/Users/Lucas J Loveless/Downloads/ReBot/CombatRotations/Default/Hunter/TestHunter.cs", client.DownloadString("https://raw.githubusercontent.com/Jizar07/Rebot-Combat-Rotations/master/Hunter/Survivalist.cs"));
                    return;
                }
			}
		
			PullSpells = new string[]
			{
				"Concussive Shot",
				"Arcane Shot",
			};
		}


		public override bool OutOfCombat()
		{
			if (CastSelfPreventDouble("Lone Wolf: Ferocity of the Raptor", () => UsePetOrLWopt == UsePetOrLWtyp.LoneWolfCrit && !HasAura("Lone Wolf: Ferocity of the Raptor") && !HasAura("Arcane Brilliance") && !HasAura("Dalaran Brilliance") && !HasAura("Leader of the Pack") && !HasAura("Legacy of the White Tiger"),1500)) return true;
			
			if (CastSelfPreventDouble("Lone Wolf: Grace of the Cat", () => UsePetOrLWopt == UsePetOrLWtyp.LoneWolfMastery && !HasAura("Lone Wolf: Grace of the Cat") && !HasAura("Blessing of Might") && !HasAura("Power of the Grave") && !HasAura("Grace of Air") && !HasAura("Moonkin Aura"),1500)) return true;
			
			if (CastSelfPreventDouble("Lone Wolf: Haste of the Hyena", () => UsePetOrLWopt == UsePetOrLWtyp.LoneWolfHaste && !HasAura("Lone Wolf: Haste of the Hyena") && !HasAura("Unholy Aura") && !HasAura("Grace of Air") && !HasAura("Mind Quickening") && !HasAura("Swiftblade's Cunning"),1500)) return true;
			
			if (CastSelfPreventDouble("Lone Wolf: Power of the Primates", () => UsePetOrLWopt == UsePetOrLWtyp.LoneWolfStats && !HasAura("Lone Wolf: Power of the Primates") && !HasAura("Lone Wolf: Haste of the Hyena") && !HasAura("Blessing of Kings") && !HasAura("Mark of the Wild") && !HasAura("Legacy of the Emperor"),1500)) return true;
			
			if (CastSelfPreventDouble("Lone Wolf: Fortitude of the Bear", () => UsePetOrLWopt == UsePetOrLWtyp.LoneWolfStamina && !HasAura("Lone Wolf: Fortitude of the Bear") && !HasAura("Power Word: Fortitude") && !HasAura("Blood Pack") && !HasAura("Commanding Shout"),1500)) return true;
			
			if (CastSelfPreventDouble("Lone Wolf: Quickness of the Dragonhawk", () => UsePetOrLWopt == UsePetOrLWtyp.LoneWolfMultistrike && !HasAura("Lone Wolf: Quickness of the Dragonhawk") && !HasAura("Windflurry") && !HasAura("Mind Quickening") && !HasAura("Swiftblade's Cunning") && !HasAura("Dark Intent"),1500)) return true;
			
			if (CastSelfPreventDouble("Lone Wolf: Versatility of the Ravager", () => UsePetOrLWopt == UsePetOrLWtyp.LoneWolfVersatility && !HasAura("Lone Wolf: Versatility of the Ravager") && !HasAura("Sanctity Aura") && !HasAura("Inspiring Presence") && !HasAura("Unholy Aura") && !HasAura("Mark of the Wild"),1500)) return true;
			
			if (CastSelfPreventDouble("Lone Wolf: Wisdom of the Serpent", () => UsePetOrLWopt == UsePetOrLWtyp.LoneWolfSpellpower && !HasAura("Lone Wolf: Wisdom of the Serpent") && !HasAura("Arcane Brilliance") && !HasAura("Dalaran Brilliance") && !HasAura("Dark Intent"),1500)) return true;
			
			CastSelf("Trap Launcher", () => !HasAura("Trap Launcher"));

			//Camouflage
			if (Camo)
			{
				CastSelf("Camouflage", () => !HasAura("Camouflage")); 
			}
			
			if (Cheetah) 
			{
				if (CastSelf("Aspect of the Cheetah", () => Me.MovementSpeed != 0 && !Me.IsSwimming && Me.DisplayId == Me.NativeDisplayId && Me.DistanceTo(API.GetNaviTarget()) > 20)) return true; 
			}
		
            if (UsePetOrLWopt == UsePetOrLWtyp.UsePet)
            {
			    if (!Me.HasAlivePet)
                {
                   if (CastSelfPreventDouble("Call Pet 1", () => Me.Pet == null && PetOpt == PetTyp.PetSlot1, 5000)) return true;
                   if (CastSelfPreventDouble("Call Pet 2", () => Me.Pet == null && PetOpt == PetTyp.PetSlot2, 5000)) return true;
                   if (CastSelfPreventDouble("Call Pet 3", () => Me.Pet == null && PetOpt == PetTyp.PetSlot3, 5000)) return true;
                   if (CastSelfPreventDouble("Call Pet 4", () => Me.Pet == null && PetOpt == PetTyp.PetSlot4, 5000)) return true;
                   if (CastSelfPreventDouble("Call Pet 5", () => Me.Pet == null && PetOpt == PetTyp.PetSlot5, 5000)) return true;
                   if (CastSelfPreventDouble("Revive Pet", null, 2000)) return true;
				   return true;
			    }
            }
            else if (Me.HasAlivePet)
            {
                if (CastSelfPreventDouble("Dismiss Pet", null,3000)) return true;
            }

			if (CastSelf("Mend Pet", () => Me.HasAlivePet && Me.Pet.HealthFraction <= 0.8 && !Me.Pet.HasAura("Mend Pet"))) return true;

			return false;
		}

		public override void Combat()
		{
		
			if (CastPreventDouble("Misdirection", () => Me.HasAlivePet && MDopt == MDtyp.MisdirectionOnPetGlyphed,Me.Pet, 8000)) return;
			if (CastPreventDouble("Misdirection", () => Me.HasAlivePet && MDopt == MDtyp.MisdirectionOnPet,Me.Pet, 30000)) return;
			if (CastPreventDouble("Misdirection", () => Me.HasAlivePet && MDopt == MDtyp.MisdirectionOnFocus,Me.Focus, 30000)) return;
			
			if (Cheetah) 
			{ 
				if (CancelAura("Aspect of the Cheetah")); 
			}
			
            Cast("Counter Shot", () => Target.IsCastingAndInterruptible());
			
			if (UseTranqShot) 
			{	
				if (Cast("Tranquilizing Shot", () => Target.Auras.Any(x => x.IsStealable))) return;
			}
						
			if (Cast("Kill Shot", () => Target.HealthFraction < 0.2)) return;
			
			if (UsePetOrLWopt == UsePetOrLWtyp.UsePet)
            {		
			 
				if (Me.HasAlivePet)
				{
					if (CastSelfPreventDouble("Mend Pet", () => Me.HasAlivePet && Me.Pet.HealthFraction <= 0.8, 9000)) return;
					UnitObject add = Adds.FirstOrDefault(x => x.Target == Me);
					if (add != null)
						Me.PetAttack(add);
				}
			
				if(Intimidation)
				{		
					if (Cast("Intimidation", () => Target.IsCastingAndInterruptible())) return;
				}

	
		/// Healing Abilities
				if (HasSpell("Exhilaration")) 
				{
					CastSelf("Exhilaration", () => Me.HealthFraction <= 0.3);
				}
			
		/// Out of CC
			if (CastSelf("Master's Call", () => !Me.CanParticipateInCombat)) return;
			
			 if (!Me.HasAlivePet) {
					if (CastSelfPreventDouble("Call Pet 1", () => Me.Pet == null && PetOpt == PetTyp.PetSlot1, 5000)) return;
					if (CastSelfPreventDouble("Call Pet 2", () => Me.Pet == null && PetOpt == PetTyp.PetSlot2, 5000)) return;
					if (CastSelfPreventDouble("Call Pet 3", () => Me.Pet == null && PetOpt == PetTyp.PetSlot3, 5000)) return;
					if (CastSelfPreventDouble("Call Pet 4", () => Me.Pet == null && PetOpt == PetTyp.PetSlot4, 5000)) return;
					if (CastSelfPreventDouble("Call Pet 5", () => Me.Pet == null && PetOpt == PetTyp.PetSlot5, 5000)) return;
		
					if (CastSelf("Heart of the Phoenix")) return;
					if (CastSelfPreventDouble("Revive Pet", null, 10000)) return;
				}
			}
			else if (Me.HasAlivePet)
            {
                if (CastSelfPreventDouble("Dismiss Pet", null,3000)) return;
            }
			
		
		/// Self Protection
			if(Deterrence)
			{
				//if (CastSelfPreventDouble("Deterrence", () => Me.HealthFraction <= 0.5));
				if (CastSelfPreventDouble("Deterrence", () => Me.HealthFraction <= 0.25));
			}
			
			if (CastSelf("Exhilaration", () => Me.HealthFraction <= 0.3));
			if (CastSelfPreventDouble("Feign Death", () => Me.HealthFraction <= 0.20));
	
	
			if (HasSpell("Poisoned Ammo"))
			{
				if (CastSelfPreventDouble("Poisoned Ammo", () => !HasAura("Poisoned Ammo") && Adds.Count < 2)) return;
			}
			
		/// Rotation 1		
			/*
			if (CastOnTerrain("Explosive Trap", Target.Position, () => HasAura("Trap Launcher") && Adds.Count > 2)) return;
			if (Cast("Multi-Shot", () => Me.GetPower(WoWPowerType.Focus) >= 20 && HasAura("Thrill of the Hunt") && Adds.Count > 2)) return;
			if (Cast("Multi-Shot", () => Me.GetPower(WoWPowerType.Focus) >= 40 && Adds.Count > 2)) return;
			if (Cast("Black Arrow")) return;
			if (Cast("Explosive Shot")) return;
			if (CastSelf("Explosive Shot", () => HasAura("Lock and Load"))) return; 
			if (Cast("A Murder of Crows")) return;
			if (Cast("Stampede")) return;
			if (Cast("Dire Beast")) return;
			if (Cast("Glaive Toss")) return;
			if (Cast("Arcane Shot", () => Me.GetPower(WoWPowerType.Focus) >= 20 && HasAura("Thrill of the Hunt") && Adds.Count < 2)) return;
			if (Cast("Barrage")) return;
			if (Cast("Powershot")) return;	
			if (Cast("Arcane Shot", () => Me.GetPower(WoWPowerType.Focus) >= 30 && Adds.Count < 2)) return;
			if (Cast("Cobra Shot")) return;
			*/
		/// Rotation 2
		// AOE
			if(Adds.Count >= 3)
			{
				if(AOE)
				{
					if (CastOnTerrain("Explosive Trap", Target.Position, () => HasAura("Trap Launcher"))) return;
					if (Cast("Multi-Shot", () => Me.GetPower(WoWPowerType.Focus) >= 20 && HasAura("Thrill of the Hunt"))) return;
					if (Cast("Glaive Toss")) return;
					if (Cast("Barrage", () => Me.GetPower(WoWPowerType.Focus) >= 60)) return;
					if (Cast("Multi-Shot", () => Me.GetPower(WoWPowerType.Focus) >= 40)) return;
					if (Cast("Cobra Shot")) return;
				}
			}
		// END
			
		// SINGLE
				if (Cast("Black Arrow")) return;
				if (Cast("A Murder of Crows")) return;
				if (CastSelf("Explosive Shot", () => HasAura("Lock and Load"))) return;
				if (Cast("Arcane Shot", () => Me.GetPower(WoWPowerType.Focus) >= 20 && HasAura("Thrill of the Hunt"))) return;
				if (Cast("Explosive Shot")) return; 
				if (Cast("Dire Beast")) return;
				if (Cast("Glaive Toss")) return;
				if (Cast("Powershot")) return;	
				if (Cast("Arcane Shot", () => Me.GetPower(WoWPowerType.Focus) >= 30)) return;
				if (Cast("Cobra Shot")) return;
		}
	}
}

